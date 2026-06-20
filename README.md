<div align="center">

<h1>tmux-weather-revamped</h1>

**Weather in your tmux status bar, fetched in the background so the render never waits on the network.**

[![Tests](https://github.com/gufranco/tmux-weather-revamped/actions/workflows/tests.yml/badge.svg)](https://github.com/gufranco/tmux-weather-revamped/actions/workflows/tests.yml) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

</div>

**1** placeholder · **65** tests · **95%+** coverage

A weather lookup is an HTTP request, the slowest thing a status bar can do inline. This plugin runs `curl` with a hard timeout inside a detached worker, caches the result in a tmux server user-option, and serves the status line from that cache. No temp files are used, and a failed fetch keeps the last good reading on screen.

Inspired by [tmux-weather](https://github.com/ilya-manin/tmux-weather). Built from [tmux-plugin-template](https://github.com/gufranco/tmux-plugin-template). Weather data comes from [wttr.in](https://github.com/chubin/wttr.in).

<table>
<tr>
<td><b>Non-blocking</b><br/>The fetch runs in a detached worker, so the status render returns instantly.</td>
<td><b>No temp files</b><br/>The reading lives in a tmux server user-option, not on disk.</td>
</tr>
<tr>
<td><b>Cross-platform</b><br/>Runs anywhere `curl` is on <code>PATH</code>, on every supported architecture.</td>
<td><b>Tested</b><br/>65 tests at 95%+ coverage guard every code path.</td>
</tr>
</table>

## Placeholders

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

## Development

```sh
bats test          # run the suite
shellcheck src/**/*.sh   # lint
kcov coverage bats test  # coverage
```

## License

[MIT](LICENSE), copyright Gustavo Franco.
