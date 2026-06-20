#!/usr/bin/env bash
#
# weather.sh: weather string acquisition from wttr.in.
#
# weather_build_url is pure. The network fetch lives behind a seam and runs only
# inside the background worker, so a slow or down endpoint never blocks the render.

[[ -n "${_WEATHER_REVAMPED_WEATHER_LOADED:-}" ]] && return 0
_WEATHER_REVAMPED_WEATHER_LOADED=1

# Seconds before the HTTP request is abandoned.
WEATHER_TIMEOUT="${WEATHER_TIMEOUT:-10}"

# weather_build_url LOCATION UNITS FORMAT -> a wttr.in request URL.
weather_build_url() {
  local location="${1}" units="${2}" format="${3}"
  local unit_flag="&m"
  [[ "${units}" == "u" ]] && unit_flag="&u"
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

export -f weather_build_url
export -f _read_weather
export -f weather_fetch
