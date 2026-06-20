# tmux-weather-revamped

[![Tests](https://github.com/gufranco/tmux-weather-revamped/actions/workflows/tests.yml/badge.svg)](https://github.com/gufranco/tmux-weather-revamped/actions/workflows/tests.yml) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Weather in your tmux status bar, fetched in the background so the status render
never waits on the network.

A weather lookup is an HTTP request, which is the slowest thing a status bar can
do inline. This plugin runs `curl` with a hard timeout inside a detached worker,
caches the result in a tmux server user-option, and serves the status line from
that cache. When a fetch fails the last good reading stays on screen. No temp
files are used.

Inspired by [tmux-weather](https://github.com/ilya-manin/tmux-weather). Built
from [tmux-plugin-template](https://github.com/gufranco/tmux-plugin-template).
Weather data comes from [wttr.in](https://github.com/chubin/wttr.in).

## Placeholder

| Placeholder | Output |
|-------------|--------|
| `#{weather}` | the wttr.in one-line forecast, for example `+18C clear` |

## Install

With [TPM](https://github.com/tmux-plugins/tpm):

```tmux
set -g @plugin 'gufranco/tmux-weather-revamped'
set -g status-right '#{weather} '
```

Press `prefix + I` to install. `curl` must be on `PATH`.

## Configuration

| Option | Default | Meaning |
|--------|---------|---------|
| `@tmux-weather-location` | empty | a city or location; empty auto-detects by IP |
| `@tmux-weather-units` | `m` | `m` for metric, `u` for imperial |
| `@tmux-weather-format` | `1` | a wttr.in one-line format code |
| `@tmux-weather-interval` | `15` | minutes between background fetches |
| `@weather_revamped_enable_logging` | `0` | set to `1` to log under `~/.tmux/weather-revamped-logs` |

See the [wttr.in format options](https://github.com/chubin/wttr.in#one-line-output)
for format codes.

## Support by platform and architecture

Works on every supported platform and architecture. The only requirement is
`curl` on `PATH`, which ships with macOS (Intel and Apple Silicon) and is a one
package install on Linux (x86_64 and arm64).

## How it stays responsive

The worker fetches at most once per interval and writes the result to
`@weather_revamped_value`. The status line reads that option and returns
instantly. A failed fetch never clears the cached value, so a brief network blip
leaves the last reading in place.

## License

[MIT](LICENSE), copyright Gustavo Franco.
