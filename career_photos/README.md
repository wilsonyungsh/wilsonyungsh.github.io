# career_photos/

Story-map photos for the [career map](../career_map.html) tour, referenced by
`script/career_map.R`'s `locations$photo` column and served to `tourStops` in
the generated page.

## How it works

When the fly-through tour reaches a stop, the caption card normally shows
just text ("N / 11 · Org · Period"). If that stop has a photo, the same card
grows a 150px-tall image on top first. Stops without a photo (`NA` in the
`photo` column) look exactly as before — this is additive, not required for
every stop.

Like `career_logos/`, these load at *render time* in the visitor's browser
via a relative URL, so they need to stay same-origin (no external hosting)
and the paths in `career_map.R` need to match the filenames here exactly.

## Format

Every file is a **480×320 JPEG**, cropped to fill that frame
(`object-fit: cover` on a landscape aspect ratio) so the story card doesn't
jump around in size between stops. Quality ~82 to keep file sizes small —
these load during fast tour transitions, not on a static page.

## Current photos

| File | Stop | Notes |
|---|---|---|
| `ncku.jpg` | National Cheng Kung University | Graduation photo, supplied directly (re-supplied after the original was lost — see "A cautionary note" below) |
| `jku.jpg` | Johannes Kepler University Linz | Exchange-year photo (Hallstatt, Austria), supplied directly |
| `tainan_epa.jpg` | Tainan City Environmental Protection Bureau | Team photo, supplied directly |
| `tku.jpg` | Tamkang University | Group hiking-trip photo, supplied directly |
| `uts.jpg` | UTS | Fieldwork photo, supplied directly |
| `appen.jpg` | Appen Butler Hill | Team photo, supplied directly |
| `sgs.jpg` | SGS Economics and Planning | Team social photo, supplied directly |
| `sydwater.jpg` | Sydney Water | Team photo, supplied directly |
| `tomtom.jpg` | TomTom | Team office photo, supplied directly (replaces an earlier archery team-building photo, kept at `archive/tomtom_archery.jpg`) |
| `dspark.jpg` | DSpark (Optus) | Team photo, supplied directly |
| `gcc.jpg` | City of Gold Coast | Team photo, supplied directly |
| `bcc.jpg` | Brisbane City Council | Team photo, supplied directly |

No photo yet for: Transport for NSW.

## A cautionary note: macOS filesystems are case-insensitive

The NCKU photo was lost this way: the source file was `ncku.JPG`
(uppercase), and the processed version was written to `career_photos/ncku.jpg`
(lowercase). On macOS's default case-insensitive-but-case-preserving
filesystem, those are **the same path** — the write silently overwrote the
original's content instead of creating a second file. A follow-up
`rm career_photos/ncku.JPG`, intended to clean up the now-redundant original,
deleted that single (already-overwritten) file entirely. No trash, no git
history (it was never committed) — genuinely unrecoverable.

**Going forward**: when a processed file's name differs from its source only
by case, write the output to a clearly different temporary name first, and
only `rm` the original once the output has been verified to exist under its
own name.

## Adding or replacing one

1. Crop/resize to 480×320, matching frame:
   ```bash
   magick source.jpg -resize 480x320^ -gravity center -extent 480x320 -quality 82 career_photos/<key>.jpg
   ```
   `<key>` should match the org's `logo_key` in `career_map.R` (e.g. `ncku`,
   `tku`) for consistency, though the `photo` column can point anywhere.
2. In `script/career_map.R`, set that stop's entry in `locations$photo` to
   `"career_photos/<key>.jpg"` (was `NA`).
3. Re-run `Rscript script/career_map.R`.
