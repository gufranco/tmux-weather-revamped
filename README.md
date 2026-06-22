<div align="center">

<h1>tmux-weather-revamped</h1>

**Weather in your tmux status bar, fetched in the background so the render never waits on the network.**

[![Tests](https://github.com/gufranco/tmux-weather-revamped/actions/workflows/tests.yml/badge.svg)](https://github.com/gufranco/tmux-weather-revamped/actions/workflows/tests.yml) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

</div>

**5** placeholders · **92** tests · **95%+** coverage

A weather lookup is an HTTP request, the slowest thing a status bar can do inline. This plugin runs `curl` with a hard timeout inside a detached worker, caches the result in a tmux server user-option, and serves the status line from that cache. No temp files are used, and a failed fetch keeps the last good reading on screen.

Inspired by [tmux-weather](https://github.com/ilya-manin/tmux-weather). Built from [tmux-plugin-template](https://github.com/gufranco/tmux-plugin-template). Weather data comes from [wttr.in](https://github.com/chubin/wttr.in).

<table>
<tr>
<td><b>Non-blocking</b><br/>The fetch runs in a detached worker, so the status render returns instantly.</td>
<td><b>No temp files</b><br/>The reading lives in a tmux server user-option, not on disk.</td>
</tr>
<tr>
<td><b>Cross-platform</b><br/>Runs anywhere `curl` is on <code>PATH</code>, on every supported architecture.</td>
<td><b>Tested</b><br/>80 tests at 95%+ coverage guard every code path.</td>
</tr>
</table>

## Placeholders

| Placeholder | Output |
|-------------|--------|
| `#{weather}` | the wttr.in one-line forecast, for example `Partly cloudy +18°C` |
| `#{weather_temp}` | just the temperature, leading plus removed, for example `18°C` |
| `#{weather_condition_icon}` | a Nerd Font glyph for the sky condition, for example a sun, cloud, or rain glyph |
| `#{weather_color}` | a tmux color style for the current temperature band, for example `#[fg=green]` |
| `#{weather_icon}` | an icon for the current temperature band, empty until you set one |

Pair the color with the value, and reset afterward, to tint the reading by
temperature. A clean Nerd Font layout is the condition glyph, then the
temperature, colored by band:

```tmux
set -g status-right '#{weather_color}#{weather_condition_icon} #{weather_temp}#[default] '
```

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
| `@tmux-weather-units` | `m` | Celsius or Fahrenheit; accepts `m`/`c`/`celsius` and `u`/`f`/`fahrenheit` |
| `@tmux-weather-format` | `%C+%t` | a wttr.in one-line format code; the default carries the condition and temperature |
| `@tmux-weather-interval` | `15` | minutes between background fetches |
| `@weather_revamped_show_condition_icon` | `on` | set to `off` to hide the sky glyph from `#{weather_condition_icon}` |
| `@weather_revamped_enable_logging` | `0` | set to `1` to log under `~/.tmux/weather-revamped-logs` |

See the [wttr.in format options](https://github.com/chubin/wttr.in#one-line-output)
for format codes.

### Temperature bands

`#{weather_color}` and `#{weather_icon}` classify the current temperature into a
band, then read a per-band color and icon. The temperature is parsed from the
cached wttr.in value, so no extra fetch happens. Bands use these Celsius
thresholds:

| Band | Range (°C) | Default color | Color option | Icon option |
|------|------------|---------------|--------------|-------------|
| freezing | below 0 | `#[fg=blue]` | `@weather_revamped_freezing_color` | `@weather_revamped_freezing_icon` |
| cold | 0 to 9 | `#[fg=cyan]` | `@weather_revamped_cold_color` | `@weather_revamped_cold_icon` |
| cool | 10 to 17 | `#[fg=green]` | `@weather_revamped_cool_color` | `@weather_revamped_cool_icon` |
| comfortable | 18 to 23 | `#[fg=green]` | `@weather_revamped_comfortable_color` | `@weather_revamped_comfortable_icon` |
| hot | 24 to 31 | `#[fg=yellow]` | `@weather_revamped_hot_color` | `@weather_revamped_hot_icon` |
| very_hot | 32 and up | `#[fg=red]` | `@weather_revamped_very_hot_color` | `@weather_revamped_very_hot_icon` |

Every icon option defaults to empty, so no Nerd Font is required. Set the ones
you want:

```tmux
set -g @weather_revamped_freezing_icon 'COLD '
set -g @weather_revamped_hot_color '#[fg=colour208]'
```

When the temperature cannot be parsed, both placeholders render empty.

### Sky conditions

`#{weather_condition_icon}` reads the wttr.in condition text and maps it to a
Nerd Font weather glyph. For this to work the fetch format must include the
condition, which the default `@tmux-weather-format` of `%C+%t` already does.
Conditions are normalized into six keys, each with a Nerd Font default that you
can override:

| Key | Matches conditions containing | Icon option |
|-----|-------------------------------|-------------|
| clear | sun, clear | `@weather_revamped_clear_condition_icon` |
| clouds | cloud, overcast | `@weather_revamped_clouds_condition_icon` |
| rain | rain, drizzle, shower | `@weather_revamped_rain_condition_icon` |
| snow | snow, sleet, blizzard, ice | `@weather_revamped_snow_condition_icon` |
| storm | thunder, storm | `@weather_revamped_storm_condition_icon` |
| fog | fog, mist, haze | `@weather_revamped_fog_condition_icon` |

Storm and snow are matched before rain, so a thundery shower maps to storm and
sleet to snow. Override any key to a different glyph or plain text:

```tmux
set -g @weather_revamped_rain_condition_icon 'RAIN'
```

## Theme color suggestions

The defaults use the 16 ANSI color names, which the active terminal theme remaps,
so the bands match whatever theme you run out of the box. For exact hex values
that pin a band to a specific shade, copy one block below.

### Catppuccin Mocha

```tmux
set -g @weather_revamped_freezing_color '#[fg=#89b4fa]'
set -g @weather_revamped_cold_color '#[fg=#94e2d5]'
set -g @weather_revamped_cool_color '#[fg=#a6e3a1]'
set -g @weather_revamped_comfortable_color '#[fg=#a6e3a1]'
set -g @weather_revamped_hot_color '#[fg=#f9e2af]'
set -g @weather_revamped_very_hot_color '#[fg=#f38ba8]'
```

### Dracula

```tmux
set -g @weather_revamped_freezing_color '#[fg=#bd93f9]'
set -g @weather_revamped_cold_color '#[fg=#8be9fd]'
set -g @weather_revamped_cool_color '#[fg=#50fa7b]'
set -g @weather_revamped_comfortable_color '#[fg=#50fa7b]'
set -g @weather_revamped_hot_color '#[fg=#f1fa8c]'
set -g @weather_revamped_very_hot_color '#[fg=#ff5555]'
```

### Nord

```tmux
set -g @weather_revamped_freezing_color '#[fg=#81a1c1]'
set -g @weather_revamped_cold_color '#[fg=#88c0d0]'
set -g @weather_revamped_cool_color '#[fg=#a3be8c]'
set -g @weather_revamped_comfortable_color '#[fg=#a3be8c]'
set -g @weather_revamped_hot_color '#[fg=#ebcb8b]'
set -g @weather_revamped_very_hot_color '#[fg=#bf616a]'
```

### Gruvbox Dark

```tmux
set -g @weather_revamped_freezing_color '#[fg=#83a598]'
set -g @weather_revamped_cold_color '#[fg=#8ec07c]'
set -g @weather_revamped_cool_color '#[fg=#b8bb26]'
set -g @weather_revamped_comfortable_color '#[fg=#b8bb26]'
set -g @weather_revamped_hot_color '#[fg=#fabd2f]'
set -g @weather_revamped_very_hot_color '#[fg=#fb4934]'
```

### Tokyo Night

```tmux
set -g @weather_revamped_freezing_color '#[fg=#7aa2f7]'
set -g @weather_revamped_cold_color '#[fg=#7dcfff]'
set -g @weather_revamped_cool_color '#[fg=#9ece6a]'
set -g @weather_revamped_comfortable_color '#[fg=#9ece6a]'
set -g @weather_revamped_hot_color '#[fg=#e0af68]'
set -g @weather_revamped_very_hot_color '#[fg=#f7768e]'
```

### Solarized Dark

```tmux
set -g @weather_revamped_freezing_color '#[fg=#268bd2]'
set -g @weather_revamped_cold_color '#[fg=#2aa198]'
set -g @weather_revamped_cool_color '#[fg=#859900]'
set -g @weather_revamped_comfortable_color '#[fg=#859900]'
set -g @weather_revamped_hot_color '#[fg=#b58900]'
set -g @weather_revamped_very_hot_color '#[fg=#dc322f]'
```

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
