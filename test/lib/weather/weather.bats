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
