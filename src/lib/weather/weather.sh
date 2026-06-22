#!/usr/bin/env bash
#
# weather.sh: weather string acquisition from wttr.in.
#
# weather_build_url is pure. The network fetch lives behind a seam and runs only
# inside the background worker, so a slow or down endpoint never blocks the render.

[[ -n "${_WEATHER_REVAMPED_WEATHER_LOADED:-}" ]] && return 0
_WEATHER_REVAMPED_WEATHER_LOADED=1

_WEATHER_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "${_WEATHER_SCRIPT_DIR}/../tmux/tmux-ops.sh"

# Seconds before the HTTP request is abandoned.
WEATHER_TIMEOUT="${WEATHER_TIMEOUT:-10}"

# weather_build_url LOCATION UNITS FORMAT -> a wttr.in request URL.
weather_build_url() {
  local location="${1}" units="${2}" format="${3}"
  # Accept friendly aliases for the unit: Fahrenheit and Celsius spellings, plus
  # the wttr.in m and u flags. Anything unrecognized falls back to metric.
  local unit_flag
  case "${units}" in
    u | f | F | fahrenheit | Fahrenheit | imperial) unit_flag="&u" ;;
    *) unit_flag="&m" ;;
  esac
  echo "https://wttr.in/${location}?format=${format}${unit_flag}"
}

# Host-probe seam. Tests override this.
_read_weather() {
  curl -s --max-time "${WEATHER_TIMEOUT}" "${1}" 2>/dev/null
}

# weather_fetch URL -> the response body, empty on failure or a wttr.in error.
weather_fetch() {
  local body
  body=$(_read_weather "${1}")
  # wttr.in returns a plain error sentence when a location cannot be resolved.
  case "${body}" in
    *"Unknown location"*|*"ERROR"*|*"Sorry"*) echo "" ;;
    *) printf '%s' "${body}" ;;
  esac
}

# weather_temp_from_text TEXT -> the signed integer temperature, empty when none.
# A wttr.in one-line value carries the temperature as a signed number before a
# degree mark, for example "+18C clear" or "-3°C". The awk grabs the first such
# token and strips its sign-preserving prefix.
weather_temp_from_text() {
  local text="${1}"
  echo "${text}" | awk 'match($0, /[+-]?[0-9]+°?[CF]/) { s=substr($0, RSTART, RLENGTH); gsub(/[^0-9+-]/, "", s); print s+0; exit }'
}

# weather_band CELSIUS -> a temperature band name, empty when CELSIUS is not an
# integer. Thresholds are hardcoded: freezing <0, cold 0-9, cool 10-17,
# comfortable 18-23, hot 24-31, very_hot >=32.
weather_band() {
  local celsius="${1}"
  [[ "${celsius}" =~ ^-?[0-9]+$ ]] || return 0
  if (( celsius < 0 )); then
    echo "freezing"
  elif (( celsius <= 9 )); then
    echo "cold"
  elif (( celsius <= 17 )); then
    echo "cool"
  elif (( celsius <= 23 )); then
    echo "comfortable"
  elif (( celsius <= 31 )); then
    echo "hot"
  else
    echo "very_hot"
  fi
}

# _weather_band_default_color BAND -> the built-in color for a band.
_weather_band_default_color() {
  case "${1}" in
    freezing)    echo "#[fg=blue]" ;;
    cold)        echo "#[fg=cyan]" ;;
    cool)        echo "#[fg=green]" ;;
    comfortable) echo "#[fg=green]" ;;
    hot)         echo "#[fg=yellow]" ;;
    very_hot)    echo "#[fg=red]" ;;
    *)           echo "" ;;
  esac
}

# weather_render_color TEXT -> the tmux color style for the temperature in TEXT,
# read from @weather_revamped_<band>_color, empty when no band is parsed.
weather_render_color() {
  local band
  band=$(weather_band "$(weather_temp_from_text "${1}")")
  [[ -z "${band}" ]] && return 0
  get_tmux_option "@weather_revamped_${band}_color" "$(_weather_band_default_color "${band}")"
}

# weather_render_icon TEXT -> the icon for the temperature in TEXT, read from
# @weather_revamped_<band>_icon, empty by default so no Nerd Font is required.
weather_render_icon() {
  local band
  band=$(weather_band "$(weather_temp_from_text "${1}")")
  [[ -z "${band}" ]] && return 0
  get_tmux_option "@weather_revamped_${band}_icon" ""
}

# weather_temp_display_from_text TEXT -> the temperature token for display, with a
# leading plus removed, for example "Partly cloudy +25°C" -> "25°C".
weather_temp_display_from_text() {
  local tok
  tok=$(echo "${1}" | awk 'match($0, /[+-]?[0-9]+°?[CF]/) { print substr($0, RSTART, RLENGTH); exit }')
  printf '%s' "${tok#+}"
}

# weather_condition_from_text TEXT -> the sky condition words, the part of TEXT
# before the temperature token, for example "Partly cloudy +25°C" -> "Partly
# cloudy". Empty when no temperature is present.
weather_condition_from_text() {
  echo "${1}" | awk 'match($0, /[+-]?[0-9]+°?[CF]/) { c=substr($0, 1, RSTART-1); gsub(/(^[ \t]+|[ \t]+$)/, "", c); print c; exit }'
}

# weather_condition_key CONDITION -> a normalized key. Storm and snow are checked
# before rain so "thundery rain" maps to storm and "sleet" to snow.
weather_condition_key() {
  local c
  c=$(printf '%s' "${1}" | tr '[:upper:]' '[:lower:]')
  case "${c}" in
    *thunder* | *storm*) echo "storm" ;;
    *snow* | *sleet* | *blizzard* | *ice*) echo "snow" ;;
    *rain* | *drizzle* | *shower*) echo "rain" ;;
    *fog* | *mist* | *haze*) echo "fog" ;;
    *overcast* | *cloud*) echo "clouds" ;;
    *) echo "clear" ;;
  esac
}

# weather_condition_default_icon KEY -> the built-in Nerd Font weather glyph,
# emitted through printf escapes so no literal glyph lives in the source.
weather_condition_default_icon() {
  case "${1}" in
    clouds) printf '' ;;
    rain)   printf '' ;;
    snow)   printf '' ;;
    storm)  printf '' ;;
    fog)    printf '' ;;
    *)      printf '' ;;
  esac
}

# weather_render_condition_icon TEXT -> the Nerd Font glyph for the sky condition
# in TEXT, overridable via @weather_revamped_<key>_condition_icon.
weather_render_condition_icon() {
  # A single switch to hide the sky glyph without editing the status format.
  case "$(get_tmux_option "@weather_revamped_show_condition_icon" "on")" in
    off | 0 | no | false) return 0 ;;
  esac
  local key
  key=$(weather_condition_key "$(weather_condition_from_text "${1}")")
  get_tmux_option "@weather_revamped_${key}_condition_icon" "$(weather_condition_default_icon "${key}")"
}

export -f weather_build_url
export -f _read_weather
export -f weather_fetch
export -f weather_temp_from_text
export -f weather_band
export -f _weather_band_default_color
export -f weather_render_color
export -f weather_render_icon
export -f weather_temp_display_from_text
export -f weather_condition_from_text
export -f weather_condition_key
export -f weather_condition_default_icon
export -f weather_render_condition_icon
