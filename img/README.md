# img/

Homepage-only images — the hero banner and profile avatar on
[index.html](../index.html), referenced from `content.R`'s `hero$photo` /
`hero$avatar`. Not related to the career map's own asset folders
(`career_logos/`, `career_photos/`, `career_gis_maps/`), which feed
[career_map.html](../career_map.html) instead.

## How it's used

The hero is a "cover photo + avatar" layout (see the design review that
picked it — `A2` on the Blue Mountains Banner Options canvas):

- `hero$photo` fills a full-width, full-bleed banner right below the nav
  (breaks out of the page's normal `max-width: 900px` container on purpose).
  No text sits on top of it — that collided with the avatar in an earlier
  version.
- `hero$avatar` is a small circle that overlaps the banner/page boundary via
  a negative `margin-top` (an ordinary flow element pulled up over the
  banner, not two independently-positioned absolute elements) — the classic
  LinkedIn/Facebook cover-photo pattern. The title, description and chips
  all sit in normal document flow below it, so nothing can overlap the
  avatar regardless of viewport width.

CSS: `.hero-banner`, `.hero-banner-img`, `.hero-banner-overlay`,
`.hero-avatar` in `script/build.R`.

## Current images

| File | Used as | Source |
|---|---|---|
| `blue_mountain.jpg` | Hero banner | The Three Sisters, Blue Mountains NSW, supplied directly |
| `feature_photo.jpg` | Profile avatar | Supplied directly (previously used as the hero photo itself, before the banner redesign) |
| `tree_measuring.png` | *(not wired in yet)* | Supplied directly — a fieldwork photo, also reused at `career_photos/uts.jpg` for UTS's story card. Was one option for a section background in the banner design review; not chosen yet. |

## Format

No fixed crop like the career map's asset folders — the banner is
`object-fit: cover` at whatever aspect ratio it's given (roughly
landscape/4:3 works best; portrait photos will crop hard on wide screens),
and the avatar is `object-fit: cover` inside a 104×104 circle (any aspect
ratio works, centre-cropped). Resize large originals down before adding
one — 1600–1800px on the long side, JPEG quality ~85, is plenty for a
photo that never displays above ~1280px wide.

## Adding or replacing one

1. Resize if the source is large:
   ```bash
   magick source.jpg -resize '1800x1800>' -quality 85 img/<name>.jpg
   ```
   **Case-insensitive-filesystem warning**: if the processed filename
   differs from the source only by case (e.g. `Source.JPG` →
   `source.jpg`), write to a clearly different temp name first, confirm
   it exists as its own file, then delete the source and rename — macOS
   treats those as the *same path* and a naive overwrite-then-delete can
   destroy the only copy. (This happened once, to the career map's NCKU
   photo — see `career_photos/README.md`.)
2. In `script/content.R`, set `content$hero$photo` or `$avatar` (plus the
   matching `_alt_en`/`_alt_zh`) to `"img/<name>.jpg"`.
3. Re-run `Rscript script/build.R`.
