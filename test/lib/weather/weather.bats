#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
  unset _WEATHER_REVAMPED_WEATHER_LOADED
  source "${BATS_TEST_DIRNAME}/../../../src/lib/weather/weather.sh"
}

teardown() {
  cleanup_test_environment
}

@test "weather.sh - weather_build_url uses metric by default" {
  [[ "$(weather_build_url London m 1)" == "https://wttr.in/London?format=1&m" ]]
}

@test "weather.sh - weather_build_url uses imperial when requested" {
  [[ "$(weather_build_url London u 1)" == "https://wttr.in/London?format=1&u" ]]
}

@test "weather.sh - weather_build_url allows an empty location" {
  [[ "$(weather_build_url '' m 3)" == "https://wttr.in/?format=3&m" ]]
}

@test "weather.sh - weather_fetch returns a successful body" {
  _read_weather() { echo "Partly cloudy 18°C"; }
  [[ "$(weather_fetch "http://x")" == "Partly cloudy 18°C" ]]
}

@test "weather.sh - weather_fetch is empty for an unknown location" {
  _read_weather() { echo "Unknown location: zzz"; }
  [[ -z "$(weather_fetch "http://x")" ]]
}

@test "weather.sh - weather_fetch is empty for a server error" {
  _read_weather() { echo "ERROR: upstream"; }
  [[ -z "$(weather_fetch "http://x")" ]]
}

@test "weather.sh - weather_fetch is empty when the probe is empty" {
  _read_weather() { echo ""; }
  [[ -z "$(weather_fetch "http://x")" ]]
}

@test "weather.sh - weather_temp_from_text reads a positive temperature" {
  [[ "$(weather_temp_from_text "+18°C clear")" == "18" ]]
}

@test "weather.sh - weather_temp_from_text reads a negative temperature" {
  [[ "$(weather_temp_from_text "-3°C snow")" == "-3" ]]
}

@test "weather.sh - weather_temp_from_text reads an unsigned fahrenheit value" {
  [[ "$(weather_temp_from_text "64F sunny")" == "64" ]]
}

@test "weather.sh - weather_temp_from_text is empty when no temperature is present" {
  [[ -z "$(weather_temp_from_text "partly cloudy")" ]]
}

@test "weather.sh - weather_band classifies freezing" {
  [[ "$(weather_band -5)" == "freezing" ]]
}

@test "weather.sh - weather_band classifies cold" {
  [[ "$(weather_band 5)" == "cold" ]]
}

@test "weather.sh - weather_band classifies cool" {
  [[ "$(weather_band 15)" == "cool" ]]
}

@test "weather.sh - weather_band classifies comfortable" {
  [[ "$(weather_band 20)" == "comfortable" ]]
}

@test "weather.sh - weather_band classifies hot" {
  [[ "$(weather_band 28)" == "hot" ]]
}

@test "weather.sh - weather_band classifies very_hot" {
  [[ "$(weather_band 35)" == "very_hot" ]]
}

@test "weather.sh - weather_band is empty for a non-integer" {
  [[ -z "$(weather_band "abc")" ]]
}

@test "weather.sh - _weather_band_default_color maps every band" {
  [[ "$(_weather_band_default_color freezing)" == "#[fg=blue]" ]]
  [[ "$(_weather_band_default_color cold)" == "#[fg=cyan]" ]]
  [[ "$(_weather_band_default_color cool)" == "#[fg=green]" ]]
  [[ "$(_weather_band_default_color comfortable)" == "#[fg=green]" ]]
  [[ "$(_weather_band_default_color hot)" == "#[fg=yellow]" ]]
  [[ "$(_weather_band_default_color very_hot)" == "#[fg=red]" ]]
  [[ -z "$(_weather_band_default_color nonsense)" ]]
}

@test "weather.sh - weather_render_color uses the band default" {
  [[ "$(weather_render_color "+20°C clear")" == "#[fg=green]" ]]
}

@test "weather.sh - weather_render_color colors a freezing reading blue" {
  [[ "$(weather_render_color "-5°C snow")" == "#[fg=blue]" ]]
}

@test "weather.sh - weather_render_color colors a very hot reading red" {
  [[ "$(weather_render_color "+35°C")" == "#[fg=red]" ]]
}

@test "weather.sh - weather_render_color honors the band option" {
  set_tmux_option "@weather_revamped_hot_color" "#[fg=magenta]"
  [[ "$(weather_render_color "+28°C")" == "#[fg=magenta]" ]]
}

@test "weather.sh - weather_render_color passes a named color through verbatim" {
  set_tmux_option "@weather_revamped_hot_color" "#[fg=red]"
  [[ "$(weather_render_color "+28°C")" == "#[fg=red]" ]]
}

@test "weather.sh - weather_render_color passes a 256-palette color through verbatim" {
  set_tmux_option "@weather_revamped_hot_color" "#[fg=colour203]"
  [[ "$(weather_render_color "+28°C")" == "#[fg=colour203]" ]]
}

@test "weather.sh - weather_render_color passes a hex foreground through verbatim" {
  set_tmux_option "@weather_revamped_hot_color" "#[fg=#f38ba8]"
  [[ "$(weather_render_color "+28°C")" == "#[fg=#f38ba8]" ]]
}

@test "weather.sh - weather_render_color passes a hex fg and bg pair through verbatim" {
  set_tmux_option "@weather_revamped_hot_color" "#[fg=#f38ba8,bg=#1e1e2e]"
  [[ "$(weather_render_color "+28°C")" == "#[fg=#f38ba8,bg=#1e1e2e]" ]]
}

@test "weather.sh - weather_render_color passes a bright color name through verbatim" {
  set_tmux_option "@weather_revamped_hot_color" "#[fg=brightred]"
  [[ "$(weather_render_color "+28°C")" == "#[fg=brightred]" ]]
}

@test "weather.sh - weather_render_color is empty without a parseable temperature" {
  [[ -z "$(weather_render_color "partly cloudy")" ]]
}

@test "weather.sh - weather_render_icon is empty by default" {
  [[ -z "$(weather_render_icon "+20°C clear")" ]]
}

@test "weather.sh - weather_render_icon honors the band option" {
  set_tmux_option "@weather_revamped_freezing_icon" "ICE"
  [[ "$(weather_render_icon "-5°C")" == "ICE" ]]
}

@test "weather.sh - weather_render_icon is empty without a parseable temperature" {
  [[ -z "$(weather_render_icon "partly cloudy")" ]]
}
