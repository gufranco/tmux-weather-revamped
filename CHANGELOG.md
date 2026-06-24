# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.0] - 2026-06-23

### Added

- `@tmux-weather-hide-units` drops the C or F unit letter from `#{weather_temp}`
  for a tighter status bar (upstream tmux-weather PR #4).

### Fixed

- A place name with spaces, like `New York`, now builds a valid request URL
  instead of breaking on the bare space (upstream tmux-weather #14).
- Temperature parsing no longer depends on the awk locale. The optional degree
  mark was matched as a multibyte literal, which failed under a byte-oriented
  awk such as mawk and dropped readings that had no degree symbol. The pattern
  now uses a portable character class.

### Changed

- Reviewed the upstream `ilya-manin/tmux-weather` issues. The leading plus on a
  positive temperature is already stripped (#13), an empty location already
  auto-detects by IP (PR #16), and the background-fetch design already avoids the
  "no server running" startup spam (#18).

## [1.1.0] - 2026-06-20

### Added

- The `#{weather_color}` and `#{weather_icon}` placeholders, which color and
  icon the reading by temperature band. Bands range from freezing through
  very_hot, each with a configurable color and icon, parsed from the cached
  value with no extra fetch.

## [1.0.0] - 2026-06-19

### Added

- The `#{weather}` placeholder, backed by wttr.in.
- Non-blocking design: `curl` runs with a hard timeout inside a background worker
  and the status line reads a cached tmux user-option, with no temp files.
- Configurable location, units, one-line format, and fetch interval.
- A failed fetch keeps the last good reading on screen.
