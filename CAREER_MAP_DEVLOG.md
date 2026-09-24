# Career Map — Debug Journey & Architecture

Internal devlog for [career_map.html](career_map.html) — a personal note on how
it's built and, more usefully, a record of what actually broke and why,
so a future bug in the same neighbourhood doesn't take three debugging
sessions to find again.

## Architecture

One R script, `script/career_map.R`, generates one self-contained HTML file.
No server, no build step beyond `Rscript script/career_map.R`.

```
locations (data.frame, 11 rows)
  id, org, role, period, city, industry, lng, lat, has_fieldwork, photo
        │
        ├─ industry_colours          6 categories → legend + halo colour
        ├─ logo_url / logo_key       → career_logos/*.png (white circular badge)
        ├─ photo                    → career_photos/*.jpg (story-card, optional)
        ├─ career_maps[[org]]        → career_gis_maps/{thumbs,full}/*.jpg (popup gallery, optional)
        └─ popup_html / tour data    → serialised to JS, embedded in the widget
                │
                ▼
        mapgl::maplibre()            base map (MapLibre GL JS, dark-matter style)
          + add_circle_layer()       halo + main dot per location
          + add_symbol_layer()       period labels
          + htmlwidgets::onRender()  everything dynamic, added at runtime:
                - logo symbol layer (loadImage → addImage → addLayer)
                - deck.gl ArcLayer, loaded from CDN, interleaved via MapboxOverlay
                - legend, tour transport controls, speed slider (plain DOM injection)
                - tour state machine (play/pause/prev/next/restart)
                │
                ▼
        htmlwidgets::saveWidget(selfcontained = TRUE) → career_map.html
```

**Three asset folders, one pattern each:**

| Folder | What | Shown |
|---|---|---|
| `career_logos/` | Company/institution logos, white circular badge (real brand colour kept for UTS, DSpark) | On the map, always |
| `career_photos/` | Team/self photos, 480×320 | Tour's flying caption card, only stops that have one |
| `career_gis_maps/{thumbs,full}/` | Past GIS project outputs, 160×110 thumb → ≤1200px full | Click-popup gallery, only stops that have any |

Each has its own `README.md` documenting exactly how each asset was sourced —
because "where did this logo come from" is exactly the kind of thing that's
obvious today and a mystery in six months.

## Debug journey

Roughly chronological. Commit hashes from `git log` where useful.

### 1. Too many legend categories (`d845afe`)
Started with 9 chapter labels, nearly 1:1 with the 10 locations — not a
legend, just a list. Consolidated into **6 industry categories**
(Education & Academia, Water Resources, Data & Fieldwork Services, Urban &
Land Use Planning, Commercial Map Production, Transport & Mobility Data),
re-derived from what each role actually *was*, not the career narrative
(e.g. TomTom is "Commercial Map Production", not "GIS industry").

### 2. Logos didn't load — attempt 1 (`911c1a0`)
First pass used Google's favicon service and Simple Icons' SVG CDN. Both
failed **silently** — no error, no logo, nothing to grep for:

- Google's `s2/favicons` endpoint now 301-redirects to a `gstatic.com`
  URL that itself returns 404 (with a blank fallback image body).
- Simple Icons serves SVG; `MapLibre#loadImage()` only decodes raster
  formats, so it can't rasterise them.

Fix: download real logos, composite each onto a white circular badge
locally with ImageMagick, host as static PNGs in `career_logos/`,
reference by relative (same-origin) path. Same-origin also sidesteps any
CORS question entirely.

### 3. Logos *still* didn't load — attempt 2, the real bug (`bcb9881`)
Hosting the files locally didn't fix it. The actual bug: this bundled
MapLibre GL JS version's `Map#loadImage(url)` is **Promise-based** — one
argument, resolves `{data: image}`. The code was calling it Mapbox-GL-style,
`loadImage(url, callback)`. The call "succeeded" (no error) and the
callback was simply never invoked, so the counter that gated
`addLayer()` never reached its target — no error, no image, no layer.

This one needed an actual live browser to catch, since it's a callback
that silently never fires rather than something that throws. Chrome
headless kept rendering garbage (a literal 3D-globe artifact instead of
the flat map — see #6) and `execute javascript` via AppleScript was
blocked by a Chrome security setting that can't be toggled headlessly.
What worked: open the real page in a real (non-headless) Chrome, inject
a small polling script that writes its findings into `document.title`,
and read the title back with `osascript`. That's a workaround for "I
have shell access but not a debugger" — worth remembering next time
something needs live browser state and a proper devtools session isn't
available.

Fix: switch to `.then()/.catch()`.

### 4. Arcs were flat (`947089a`)
The lines connecting each career stop were originally a hand-rolled
quadratic-Bezier curve sampled into a MapLibre `line` layer — curved when
viewed from above, but MapLibre lines have **no z-height**, so at any
pitch they read as flat, nothing like the genuinely 3D arcs `mapdeck`
(the R deck.gl binding) produces.

Fix: drop the Bezier math entirely and load **deck.gl** from a CDN at
render time, adding a real `ArcLayer` via `MapboxOverlay` on top of the
MapLibre map — the same rendering engine `mapdeck` uses, with true
elevation, a source→target colour gradient, and `greatCircle: true` for
the one long Taiwan→Sydney hop.

### 5. Arcs still invisible — two more causes stacked (`6ab9ea9`)
Even with real deck.gl geometry, nothing showed up at the default view.
Two independent problems, found by testing an isolated minimal
MapLibre+deck.gl page first (confirmed the *technique* works), then
re-adding the real data with deliberately garish styling (confirmed
it *was* rendering, just invisible):

- **Too faint.** Original styling was 2.5px wide at partial opacity —
  technically rendering, indistinguishable from "not rendering" against
  the dark basemap. Bumped to full opacity, width 4.
- **Globe projection.** MapLibre auto-switches to a 3D globe at low
  zoom levels, and the initial zoom (3.5) falls inside that range.
  deck.gl's overlay only tracks flat Mercator, so while the globe was
  active the arc had nowhere valid to project onto. Fixed by forcing
  `mlmap.setProjection({type: 'mercator'})` as soon as the map instance
  is available — keeps it consistent with every other layer, which all
  assumed flat Mercator from the start.

Net effect: three unrelated bugs (favicon/SVG, callback vs Promise,
globe projection) all presented as the same symptom — "nothing shows up,
no error" — and needed three different kinds of evidence to tell apart
(HTTP status codes, live JS state, an isolated test page).

### 6. A privacy near-miss with screenshots
While chasing the arc-visibility bug, `screencapture` was used to verify
visually. It captured the **actual live screen** — not an isolated test
window — twice, showing real browsing (Google Maps, Facebook) that had
nothing to do with the task. Caught immediately, images deleted without
being referenced further, and screenshot-based verification was dropped
for the rest of the session in favour of non-visual checks: extracting
the generated JS and running `node --check` on it, `curl`-ing every
asset through a local HTTP server to confirm 200s, and — when actual
runtime state was needed — the `document.title`-polling technique from
#3. Slower, but doesn't risk capturing anything it shouldn't.

### 7. Everything after that was data, not code
Once the pipeline itself was solid, the remaining work was corrections
supplied directly by the site owner, each a small, isolated change:
chronological order (Sydney Water actually preceded TomTom, `30ede8a`),
a missing stop (City of Gold Coast, `d843454`), coordinate precision
(specific buildings for NCKU/Tamkang/BCC; DSpark's marker was sitting in
Brisbane despite its own city label already saying "Macquarie Park →
Brisbane" — moved to the actual Optus HQ street, geocoded via OSM
Nominatim, `e8f9509`), and real logos replacing guessed ones (NCKU's
emblem and DSpark's mark supplied directly; UTS kept its official blue
field rather than being forced onto the white badge template, `6ab9ea9`
/ later commit).

### 8. Two feature additions, both prototyped before touching production
- **Story-card photos + transport controls** (`95175cc`): tested first
  in a throwaway `career_map_story_test.R` / `.html` per an explicit
  "test this before you touch the real page" request, then merged in
  once approved. Along the way the play/stop toggle became a proper
  transport widget (prev/next step to any stop directly, pause holds
  position instead of flying back to the overview, restart resets) —
  feedback from actually using the play/stop version.
- **GIS map gallery** (`ab02ce9`): 13 old project map images, matched to
  a career stop by year parsed from their filenames, shown in the
  click-popup (not the tour's photo card, which is for team/self photos
  — kept the two concerns visually separate rather than overloading one
  card with two kinds of content).

## What would help most, faced with this again

- **"No error, nothing renders" almost always means an async callback
  that's silently never called**, not a crash. Check the API surface
  (Promise vs callback) before anything else.
- **A bug can look identical to a styling problem.** Always confirm
  something registered/rendered *at all* (loud, ugly styling; a
  `hasImage`/`getLayer` check) before tuning colours or widths.
- **Isolate before integrating.** The deck.gl arc issue was only
  diagnosable once tested on a bare MapLibre+deck.gl page with no other
  moving parts — confirms the technique works before asking whether the
  full page's plumbing is wrong.
- **Screenshots need a real isolated target**, not just a window you
  think is isolated. Prefer programmatic state checks (title-polling,
  `node --check`, `curl` against a local server) unless there's a
  confirmed-safe way to capture only the right window.
