#!/usr/bin/env bash
#
# weather-revamped.tmux: TPM entry point.
#
# Replaces every #{weather*} placeholder in status-left and status-right with a
# call to the dispatcher. One background fetch carries the whole reading, so the
# render never waits on the network. Optionally binds a detail-popup key and a
# force-refresh key when the user sets them.

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WEATHER_CMD="${PLUGIN_DIR}/src/weather.sh"

# Every placeholder maps to the dispatcher subcommand of the same suffix. Listed
# longest-first is unnecessary because each token carries its closing brace, but
# the order is kept readable.
WEATHER_TOKENS="feels_like wind humidity pressure_trend pressure precip \
rain_chance umbrella uv_color uv dew_point dew_comfort moon sunrise sunset \
forecast today_high today_low tomorrow_high tomorrow_low condition_icon \
condition_tint stale_color alert color icon temp weather"

interpolate() {
  local value="${1}" token placeholder
  for token in ${WEATHER_TOKENS}; do
    if [ "${token}" = "weather" ]; then
      placeholder="#{weather}"
    else
      placeholder="#{weather_${token}}"
    fi
    value="${value//${placeholder}/#(${WEATHER_CMD} ${token})}"
  done
  echo "${value}"
}

update_option() {
  local option="${1}"
  local current
  current=$(tmux show-option -gqv "${option}")
  tmux set-option -gq "${option}" "$(interpolate "${current}")"
}

chmod +x "${WEATHER_CMD}" 2>/dev/null || true

update_option "status-left"
update_option "status-right"

# Opt-in key bindings. Unset by default so nothing clashes with user keys.
POPUP_KEY=$(tmux show-option -gqv "@tmux-weather-popup-key")
[ -n "${POPUP_KEY}" ] && tmux bind-key "${POPUP_KEY}" run-shell "${WEATHER_CMD} popup"

REFRESH_KEY=$(tmux show-option -gqv "@tmux-weather-refresh-key")
[ -n "${REFRESH_KEY}" ] && tmux bind-key "${REFRESH_KEY}" run-shell "${WEATHER_CMD} refresh"

true
