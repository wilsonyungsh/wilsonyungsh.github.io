# Site Architecture

Bird's-eye view of how [wilsonyungsh.github.io](https://wilsonyungsh.github.io)
fits together. For step-by-step "how do I update X" instructions see
[README.md](README.md); for the career map's own deep dive (including a full
debug journey) see [CAREER_MAP_DEVLOG.md](CAREER_MAP_DEVLOG.md).

## What this is

A static personal site on GitHub Pages — no backend, no database, no build
service. Every page that visits a browser is a plain `.html` file already
sitting in the repo. `.nojekyll` at the root turns off GitHub's default
Jekyll processing, which would otherwise try to run every `.md` file
through its own renderer and collide with the hand-built pages.

Two *independent* generators produce the site's HTML from R. Neither knows
about the other, and running one never touches the other's output:

```
script/content.R ──┐
                    ├─▶ script/build.R ──▶ index.html, map_list.html
      (data)        │        (templates)
                    ─┘

script/career_map.R ────────────────────▶ career_map.html
      (data + templates + JS, all in one file)
```

## The two build pipelines

### 1. `content.R` + `build.R` → `index.html`, `map_list.html`

- **`content.R`** is pure data — every string of text on the homepage and
  the full-portfolio page, in English and Traditional Chinese side by
  side (`_en` / `_zh` suffixes), plus the portfolio's link data. Nothing
  in here is HTML. Top-level sections: `meta`, `nav`, `hero`, `footprint`,
  `expertise`, `career`, `portfolio`, `map_list`, `footer`.
- **`build.R`** is pure template — small functions (`domain_card()`,
  `chapter_card()`, `port_card()`, `map_card()`, …) that each take one
  list from `content.R` and `paste0()` it into an HTML fragment, plus the
  page-level CSS and the `<script>` block that drives the EN/ZH toggle
  (`data-i18n` / `data-en` / `data-zh` attributes, swapped by a small
  `applyLang()` in the browser — no framework, no rebuild for language
  switching).
- Run with `Rscript script/build.R`. Regenerates **both** output files
  every time, even if only one page's content changed.
- The two pages share one design system (CSS custom properties for
  colour/type in both `css` and `css_map` variables inside `build.R`) —
  light theme, `DM Sans`/`DM Mono` for Latin text, `LXGW WenKai TC` as the
  fallback for anything the Latin fonts can't render (i.e. all Chinese
  text), same `--accent` blue throughout.

### 2. `career_map.R` → `career_map.html`

A single R script that builds one self-contained interactive MapLibre GL
map (via the `mapgl` package) and embeds it into `index.html` through an
`<iframe>`. Deliberately **not** wired into `build.R`'s pipeline — it's a
different kind of artifact (a `mapgl`/`htmlwidgets` widget, not a hand-built
HTML template) with its own much heavier dependency chain (`mapgl`, `sf`,
`htmlwidgets`, plus deck.gl loaded from a CDN at runtime, plus `pandoc` as
a system dependency for `saveWidget(selfcontained = TRUE)`).

Dark theme, independent of the rest of the site — it's an embedded widget,
not a content page, so it doesn't need to match the light theme outside it.

Full architecture and the debug history live in
[CAREER_MAP_DEVLOG.md](CAREER_MAP_DEVLOG.md); the short version: an
11-stop `locations` data.frame drives a MapLibre base map, a real deck.gl
`ArcLayer` for the connecting lines, a fly-through tour with transport
controls, and three sibling asset folders (`career_logos/`,
`career_photos/`, `career_gis_maps/`) each feeding one part of it.

## Directory map

| Path | Generated? | What |
|---|---|---|
| `index.html` | ✅ by `build.R` | Homepage. |
| `map_list.html` | ✅ by `build.R` | Full portfolio / map list page. |
| `career_map.html` | ✅ by `career_map.R` | Interactive career-location map, embedded into `index.html` via `<iframe>`. |
| `script/content.R` | — (source of truth) | All homepage/portfolio-page text, bilingual. |
| `script/build.R` | — (source of truth) | Templates + CSS for `index.html`/`map_list.html`. |
| `script/career_map.R` | — (source of truth) | Everything for `career_map.html`: data, map layers, JS. |
| `career_logos/` | Assets | Company/institution logos for the career map. Own `README.md`. |
| `career_photos/` | Assets | Team/self photos for the career map's tour story-cards. Own `README.md`. |
| `career_gis_maps/{thumbs,full}/` | Assets | Historical GIS project outputs, shown in the career map's click-popups. Own `README.md`. |
| `interactive/` | Mostly generated elsewhere | Standalone interactive maps/dashboards/tools — each is its own R script's output (mapdeck, MapGL, deck.gl, Shiny, etc.), linked to from the homepage's "Selected work" and the full portfolio page. Not part of either build pipeline above; each one is self-contained. |
| `.nojekyll` | — | Disables GitHub Pages' default Jekyll processing. **Don't delete.** |
| `README.md` | — | Maintenance notes — how to add a map, change text, update the career map, fonts, visitor counter. |
| `ARCHITECTURE.md` | — | This file. |
| `CAREER_MAP_DEVLOG.md` | — | Career map deep dive: architecture + full debug journey. |
| `supersded/` | Archive | Old snapshot(s), not linked from anywhere live. |

## Content model, in one sentence per page

- **`index.html`**: hero → footprint map embed → expertise domain cards →
  career chapters + stack-evolution comparison + career map embed →
  selected-work portfolio grid → footer/contact. All from `content.R`.
- **`map_list.html`**: every interactive map/tool grouped into sections
  (`content$map_list$sections`), each item optionally bilingual, optionally
  multiple links. Also EN/ZH toggle, also from `content.R`.
- **`career_map.html`**: not content-driven from `content.R` at all — its
  own `locations` data.frame inside `career_map.R` is the single source of
  truth for every marker, popup, tour stop, and legend colour.

## Deployment

Push to `main` → GitHub Pages serves the repo root directly (no Actions
build step; the HTML in the repo *is* the deployed HTML). The visitor
counter (`visitor_badge()` in `build.R`, and its own logic baked into
`career_map.R`) is a third-party badge image (visitorbadge.io) that counts
same-origin requests at render time — no analytics account, no cookies.

## When adding something new

- New homepage text or portfolio entry → edit `content.R`, run `build.R`.
- New career-map stop, logo, photo, or GIS map → edit `career_map.R` (see
  `CAREER_MAP_DEVLOG.md` and the three asset folders' READMEs), run
  `career_map.R`.
- New standalone interactive map → build it wherever makes sense, drop the
  output in `interactive/`, then link to it from `content.R` (`portfolio`
  for the homepage highlight, `map_list` for the full list) and run
  `build.R`.
