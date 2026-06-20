#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
  unset _WEATHER_REVAMPED_WEATHER_LOADED
  export CACHE_SYNC=1
  source "${BATS_TEST_DIRNAME}/../../../src/weather.sh"
}

teardown() {
  cleanup_test_environment
}

@test "weather.sh dispatcher - functions are defined" {
  function_exists main
  function_exists weather_refresh
  function_exists weather_tick
  function_exists weather_max_age
}

@test "weather.sh dispatcher - weather_max_age converts minutes to seconds" {
  [[ "$(weather_max_age)" == "900" ]]
}

@test "weather.sh dispatcher - weather_max_age honors the interval option" {
  set_tmux_option "@tmux-weather-interval" "5"
  [[ "$(weather_max_age)" == "300" ]]
}

@test "weather.sh dispatcher - weather_max_age defaults junk to 15 minutes" {
  set_tmux_option "@tmux-weather-interval" "abc"
  [[ "$(weather_max_age)" == "900" ]]
}

@test "weather.sh dispatcher - weather_refresh caches a successful fetch" {
  weather_fetch() { echo "Sunny 25°C"; }
  weather_refresh
  [[ "$(cache_get value)" == "Sunny 25°C" ]]
}

@test "weather.sh dispatcher - weather_refresh keeps the last value on failure" {
  cache_set value "Cloudy 18°C"
  weather_fetch() { echo ""; }
  weather_refresh
  [[ "$(cache_get value)" == "Cloudy 18°C" ]]
}

@test "weather.sh dispatcher - weather subcommand renders the cached value" {
  weather_fetch() { echo "Rainy 12°C"; }
  run main weather
  [[ "${output}" == "Rainy 12°C" ]]
}

@test "weather.sh dispatcher - color subcommand renders the cached band color" {
  weather_fetch() { echo "+28°C clear"; }
  run main color
  [[ "${output}" == "#[fg=yellow]" ]]
}

@test "weather.sh dispatcher - icon subcommand renders the cached band icon" {
  set_tmux_option "@weather_revamped_very_hot_icon" "HOT"
  weather_fetch() { echo "+35°C clear"; }
  run main icon
  [[ "${output}" == "HOT" ]]
}

@test "weather.sh dispatcher - unknown subcommand produces no output" {
  run main bogus
  [[ -z "${output}" ]]
}
