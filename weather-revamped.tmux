#!/usr/bin/env bash
#
# weather-revamped.tmux: TPM entry point.
#
# Replaces the #{weather} placeholder in status-left and status-right with a call
# to the dispatcher. The HTTP fetch runs in a background worker, so the render
# never waits on the network.

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WEATHER_CMD="${PLUGIN_DIR}/src/weather.sh"

interpolate() {
  local value="${1}"
  value="${value//\#\{weather_condition_icon\}/#(${WEATHER_CMD} condition_icon)}"
  value="${value//\#\{weather_color\}/#(${WEATHER_CMD} color)}"
  value="${value//\#\{weather_icon\}/#(${WEATHER_CMD} icon)}"
  value="${value//\#\{weather_temp\}/#(${WEATHER_CMD} temp)}"
  value="${value//\#\{weather\}/#(${WEATHER_CMD} weather)}"
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
