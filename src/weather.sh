#!/usr/bin/env bash
#
# weather.sh: command dispatcher for tmux-weather-revamped.
#
# Usage: weather.sh weather | refresh

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

export CACHE_PREFIX="weather_revamped"
export PLUGIN_LOG_NS="weather-revamped"

# shellcheck source=/dev/null
source "${PLUGIN_DIR}/src/lib/tmux/tmux-ops.sh"
# shellcheck source=/dev/null
source "${PLUGIN_DIR}/src/lib/utils/cache.sh"
# shellcheck source=/dev/null
source "${PLUGIN_DIR}/src/lib/weather/weather.sh"

weather_max_age() {
  local minutes
  minutes=$(get_tmux_option "@tmux-weather-interval" "15")
  [[ "${minutes}" =~ ^[0-9]+$ ]] || minutes=15
  echo $(( minutes * 60 ))
}

# weather_refresh -> fetch once. Keep the last good value when a fetch fails,
# re-stamping the timestamp so a persistent failure does not refetch every render.
weather_refresh() {
  local url value
  url=$(weather_build_url \
    "$(get_tmux_option "@tmux-weather-location" "")" \
    "$(get_tmux_option "@tmux-weather-units" "m")" \
    "$(get_tmux_option "@tmux-weather-format" "1")")
  value=$(weather_fetch "${url}")
  if [[ -n "${value}" ]]; then
    cache_set value "${value}"
  else
    cache_set value "$(cache_get value)"
  fi
}

weather_tick() {
  cache_refresh_if_stale value "$(weather_max_age)" weather_refresh
}

main() {
  local cmd="${1:-}"

  if [[ "${cmd}" == "refresh" ]]; then
    weather_refresh
    return 0
  fi

  weather_tick

  case "${cmd}" in
    weather) cache_get value ;;
    color)   weather_render_color "$(cache_get value)" ;;
    icon)    weather_render_icon "$(cache_get value)" ;;
    *)       return 0 ;;
  esac
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
