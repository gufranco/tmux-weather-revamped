# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
