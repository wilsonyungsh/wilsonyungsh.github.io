# career_gis_maps/

Thumbnail gallery of past GIS/analysis map outputs, shown in the
[career map](../career_map.html)'s **popup** (click a marker) — separate
from the tour's story-card photo, which is a team/self photo shown while
flying past. This is supporting work samples instead, referenced by the
`career_maps` list in `script/career_map.R`.

## Layout

- `thumbs/<slug>.jpg` — 160×110, cropped to fill (`object-fit: cover`).
  Small and fast to load since several can appear in one popup.
- `full/<slug>.jpg` — resized so the longest side is ≤1200px, quality 82.
  What a thumbnail opens to in a new tab on click.

Raw originals aren't kept in the repo (some were several MB) — only these
two processed sizes.

## Current maps

| Slug | Stop | Year | Label |
|---|---|---|---|
| `ncku_2002_landaudit` | National Cheng Kung University | 2002 | Land use audit |
| `ncku_2003_3d_a` | National Cheng Kung University | 2003 | 3D city model |
| `ncku_2003_3d_b` | National Cheng Kung University | 2003 | 3D city model |
| `ncku_2005_basemap` | National Cheng Kung University | 2005 | Base map |
| `ncku_2008_thesis` | National Cheng Kung University | 2008 | Thesis map |
| `uts_2016_arcgis3d` | UTS | 2016 | 3D model — ArcGIS Desktop |
| `uts_2024_qgis3d` | UTS | 2024 | 3D model — QGIS |
| `uts_2023_floodrisk` | UTS | 2023 | Flood risk analysis |
| `sgs_2014_project` | SGS Economics and Planning | 2014 | Project map |
| `tomtom_2017_heavyvehicle` | TomTom | 2017 | Heavy vehicle gap analysis |
| `dspark_2020_project` | DSpark (Optus) | 2020 | Project map |
| `dspark_2023_its` | DSpark (Optus) | 2023 | ITS project |
| `goldcoast_2024_project` | City of Gold Coast | 2024 | Project map |

No maps yet for: Tamkang University, Appen Butler Hill, Sydney Water,
Transport for NSW, Brisbane City Council.

## Adding one

1. Crop the thumbnail and resize the full version:
   ```bash
   magick source.png -resize 160x110^ -gravity center -extent 160x110 -quality 80 career_gis_maps/thumbs/<slug>.jpg
   magick source.png -resize '1200x1200>' -quality 82 career_gis_maps/full/<slug>.jpg
   ```
2. In `script/career_map.R`, add an entry to the right org's list inside
   `career_maps`: `list(year = "20xx", label = "...", slug = "<slug>")`.
   A new org needs a new top-level `"Org Name" = list(...)` entry — the key
   must match that stop's `org` string in `locations` exactly.
3. Re-run `Rscript script/career_map.R`.
