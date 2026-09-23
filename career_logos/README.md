# career_logos/

Local logo assets for the [career map](../career_map.html) markers, referenced by
`script/career_map.R`'s `logo_url` column.

## Why local files instead of a URL

The map loads these at **render time in the visitor's browser** via
`mlmap.loadImage(url, ...)`, not at build time — `htmlwidgets::saveWidget(selfcontained = TRUE)`
does not bundle them. Two external services were tried first and both failed silently
(no logos rendered, no error shown):

- `https://www.google.com/s2/favicons?...` — now 301-redirects to a `t0.gstatic.com/faviconV2`
  URL that returns `404` (with a blank fallback image body), which MapLibre's `loadImage`
  treats as an error.
- `https://cdn.simpleicons.org/...` — serves SVG, and `loadImage()` only decodes raster
  formats (PNG/JPG/WebP/GIF), so it fails to rasterise.

Hosting real PNGs in this folder makes the request same-origin (once published to
GitHub Pages) and sidesteps both problems.

## Format

Every file is a **128×128 PNG**, logo composited onto a white circular badge, then
masked to a circle. The white backing keeps low-contrast marks (e.g. UTS) visible
against the map's dark basemap, and keeps all 10 markers visually consistent
regardless of each source logo's own background colour.

## Sources (as of 2026-09-23)

| File | Org | Source |
|---|---|---|
| `ncku.png` | National Cheng Kung University | Real emblem (the red plum-blossom mark), supplied directly by the site owner and cropped from their official lockup |
| `tku.png` | Tamkang University | Real logo, `https://www.tku.edu.tw/tku/wp-content/uploads/.../TKU-logo.png` (from homepage `<link rel="icon">`) |
| `uts.png` | UTS | Monogram badge — real `favicon.ico` exists but is 16×16 and illegible even at 128px |
| `appen.png` | Appen Butler Hill | `https://icons.duckduckgo.com/ip3/appen.com.ico` |
| `sgs.png` | SGS Economics and Planning | `https://icons.duckduckgo.com/ip3/sgsep.com.au.ico` |
| `tomtom.png` | TomTom | Simple Icons brand SVG (`https://cdn.simpleicons.org/tomtom/000000`), rasterised locally with ImageMagick |
| `sydwater.png` | Sydney Water | `https://icons.duckduckgo.com/ip3/sydneywater.com.au.ico` |
| `tfnsw.png` | Transport for NSW | `https://transport.nsw.gov.au/themes/tfnsw_corp_theme/favicon.ico` |
| `optus.png` | DSpark (Optus) | `https://optus.com.au/favicon.ico` (their current "Yes" rewards app icon) |
| `bcc.png` | Brisbane City Council | `https://icons.duckduckgo.com/ip3/brisbane.qld.gov.au.ico` |

## Refreshing or replacing one

1. Get a PNG/ICO/SVG of the real logo (favicon, brand asset, whatever).
2. Composite it onto a white circular badge and mask to a circle, e.g.:
   ```bash
   magick \( -size 128x128 xc:none -fill white -draw "circle 64,64 64,4" \) \
         "source.png" -gravity center -compose over -composite \
         \( -size 128x128 xc:none -fill white -draw "circle 64,64 64,4" \) \
         -compose DstIn -composite \
         "career_logos/<key>.png"
   ```
3. Re-run `Rscript script/career_map.R`.

For a monogram fallback (no usable real logo), see the `ncku.png` / `uts.png` generation:
```bash
magick -size 128x128 xc:"#638B9E" -gravity center -fill white \
  -font "/System/Library/Fonts/Supplemental/Arial Bold.ttf" -pointsize 30 \
  -annotate 0 "ABC" logo.png
```
(then run through the same white-circle-badge step above)
