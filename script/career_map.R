# career_map.R
# Interactive career map for Wilson Yung's portfolio website
# Generates a self-contained HTML file using mapgl (MapLibre GL)
# Output: career_map.html — embed in index.html via <iframe>

library(mapgl)
library(htmlwidgets)
library(dplyr)
library(sf)

# ── Career locations ──────────────────────────────────────────────────────────
locations <- data.frame(
  id       = 1:13,
  org      = c(
    "National Cheng Kung University",
    "Johannes Kepler University Linz",
    "Tainan City Environmental Protection Bureau",
    "Tamkang University",
    "UTS / Research Assistant",
    "Appen Butler Hill",
    "SGS Economics and Planning",
    "Sydney Water",
    "TomTom",
    "Transport for NSW",
    "DSpark (Optus)",
    "City of Gold Coast",
    "Brisbane City Council"
  ),
  role     = c(
    "Urban Planning degree (B + M)",
    "Exchange Student",
    "Alternative Military Service — Soil & Water Conservation",
    "Research Planner, Water Resource Management",
    "Research Assistant + Sessional Lecturer (ongoing)",
    "Fieldwork Project Specialist",
    "GIS Researcher / Town Planner",
    "Field Service Officer",
    "GIS Engineer → Senior Sourcing Analyst",
    "Spatial Data Analyst",
    "Principal Data Science Consultant",
    "Data Scientist (Contract) — Transport Analytics",
    "Principal Research Officer, Team Lead RMU"
  ),
  period   = c(
    "2001–2007",
    "2006",
    "2008",
    "2009–2010",
    "2012–present",
    "2013–2014",
    "2014",
    "2015",
    "2015–2017",
    "2017–2018",
    "2019–2024",
    "2024–2025",
    "2025–present"
  ),
  city     = c(
    "Tainan, Taiwan(台南‧台灣)",
    "Linz, Austria",
    "Tainan, Taiwan(台南‧台灣)",
    "TamShui, Taiwan(淡水‧台灣)",
    "Sydney, Australia",
    "Chatswood, Sydney",
    "Sydney CBD",
    "Potts Hill, Sydney",
    "North Ryde, Sydney",
    "Sydney CBD",
    "Macquarie Park, Sydney → Brisbane",
    "Bundall, Gold Coast",
    "Brisbane CBD"
  ),
  industry = c(
    "Education & Academia",          # NCKU
    "Education & Academia",          # JKU Linz — exchange
    "Water Resources",               # Tainan EPA — soil & water conservation
    "Water Resources",               # Tamkang — water resource policy & management
    "Education & Academia",          # UTS
    "Data & Fieldwork Services",     # Appen
    "Urban & Land Use Planning",     # SGS
    "Water Resources",               # Sydney Water
    "Commercial Map Production",     # TomTom — not "GIS industry", they make commercial maps
    "Transport & Mobility Data",     # Transport for NSW
    "Transport & Mobility Data",     # DSpark (Optus) — telco mobility data
    "Transport & Mobility Data",     # City of Gold Coast — transport analytics, PT ticketing, micro-mobility
    "Urban & Land Use Planning"      # Brisbane City Council
  ),
  lng      = c(
    120.2156431519289,    # NCKU — 都計系館 (Dept. of Urban Planning building)
    14.317135481851603,   # JKU Linz, Austria — exchange 2006
    120.21979906289162,   # Tainan City Environmental Protection Bureau — 水土保持科
    121.44592677983286,   # Tamkang New Taipei
    151.2002,             # UTS Sydney
    151.1803,             # Chatswood (Appen)
    151.20936716143243,   # SGSEP Sydney CBD (corrected)
    151.0338,             # Sydney Water Potts Hill
    151.14550704742223,   # TomTom Lane Cove (corrected)
    151.20629833027127,   # TfNSW Sydney CBD (corrected)
    151.1208168,           # DSpark — started at Optus's Macquarie Park HQ (Optus Drive, Sydney)
    153.42410495833954,   # City of Gold Coast council office, Bundall
    153.02256254709644    # Brisbane City Council CBD
  ),
  lat      = c(
    23.000938960734327,   # NCKU — 都計系館 (Dept. of Urban Planning building)
    48.3375034858097,     # JKU Linz, Austria — exchange 2006
    22.985205434082832,   # Tainan City Environmental Protection Bureau — 水土保持科
    25.17406363863662,    # Tamkang New Taipei
    -33.8833,             # UTS Sydney
    -33.7969,             # Chatswood (Appen)
    -33.88593930086862,   # SGSEP (corrected)
    -33.9082,             # Sydney Water Potts Hill
    -33.79837208739991,   # TomTom (corrected)
    -33.88041851325041,   # TfNSW (corrected)
    -33.7852667,           # DSpark — started at Optus's Macquarie Park HQ (Optus Drive, Sydney)
    -28.035759004676077,  # City of Gold Coast council office, Bundall
    -27.470776856892282   # Brisbane City Council
  ),
  has_fieldwork = c(
    FALSE, FALSE, FALSE, FALSE, FALSE,
    TRUE,   # Appen — links to fieldtrip map
    FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE
  ),
  # Story-map photo shown as a bigger card during the tour when the
  # flythrough reaches that stop. NA = falls back to the small text-only
  # caption. See career_photos/README.md for sourcing.
  photo    = c(
    NA,                            # NCKU — photo lost to a case-insensitive-filesystem mixup (see career_photos/README.md), need it re-supplied
    "career_photos/jku.jpg",      # JKU Linz — exchange
    "career_photos/tainan_epa.jpg", # Tainan EPA — alternative military service
    NA,                            # Tamkang
    "career_photos/uts.jpg",      # UTS
    "career_photos/appen.jpg",    # Appen
    NA,                            # SGS
    "career_photos/sydwater.jpg", # Sydney Water
    "career_photos/tomtom.jpg",   # TomTom
    NA,                            # Transport for NSW
    "career_photos/dspark.jpg",   # DSpark (Optus)
    "career_photos/gcc.jpg",      # City of Gold Coast
    "career_photos/bcc.jpg"       # Brisbane City Council
  ),
  stringsAsFactors = FALSE
)

# Industry colour palette (hex) — one colour per industry sector, kept to a
# small set so the legend stays readable.
industry_colours <- c(
  "Education & Academia"      = "#638B9E",
  "Water Resources"           = "#2E9CB0",
  "Data & Fieldwork Services" = "#B5925A",
  "Urban & Land Use Planning" = "#8E7DB5",
  "Commercial Map Production" = "#5A7FA8",
  "Transport & Mobility Data" = "#4A8C6F"
)

locations <- locations |>
  mutate(colour = industry_colours[industry])

# ── Logo URLs ─────────────────────────────────────────────────────────────────
# Locally hosted PNGs in career_logos/ (128x128, white circular badge backing).
# Earlier versions pointed at Google's favicon service / Simple Icons CDN, but
# MapLibre's mlmap.loadImage() fetches these at *render time* in the visitor's
# browser — Google's favicon endpoint now 301s to a URL that 404s, and the
# Simple Icons SVGs can't be rasterised by loadImage() (it only decodes raster
# formats). Both silently failed with no error visible on the page. Hosting
# real PNGs ourselves avoids both problems and works offline / same-origin.
# See career_logos/README.md for how each one was sourced and how to refresh.
locations <- locations |>
  mutate(logo_url = c(
    "career_logos/ncku.png",
    "career_logos/jku.png",
    "career_logos/tainan_epa.png",
    "career_logos/tku.png",
    "career_logos/uts.png",
    "career_logos/appen.png",
    "career_logos/sgs.png",
    "career_logos/sydwater.png",
    "career_logos/tomtom.png",
    "career_logos/tfnsw.png",
    "career_logos/dspark.png",
    "career_logos/gcc.png",
    "career_logos/bcc.png"
  ),
  # Unique image key per dot (used as MapLibre sprite name)
  logo_key = c(
    "logo_ncku", "logo_jku", "logo_tainan_epa", "logo_tku", "logo_uts", "logo_appen", "logo_sgs",
    "logo_sydwater", "logo_tomtom", "logo_tfnsw", "logo_dspark", "logo_gcc", "logo_bcc"
  )
  )

# ── GIS map gallery (shown in popup) ─────────────────────────────────────────
# Small thumbnail gallery of past GIS/analysis map outputs per career stop —
# separate from the tour's story-card photo (that's the team/self photo
# shown while flying past; this is supporting work samples, shown on click).
# Click a thumb to open the full-size version in a new tab. Add a new stop's
# maps here, then regenerate — see career_gis_maps/README.md for sourcing
# and how the thumb/full pairs were made.
career_maps <- list(
  "National Cheng Kung University" = list(
    list(year = "2002", label = "Land use audit",  slug = "ncku_2002_landaudit"),
    list(year = "2003", label = "3D city model",    slug = "ncku_2003_3d_a"),
    list(year = "2003", label = "3D city model",    slug = "ncku_2003_3d_b"),
    list(year = "2005", label = "Base map",         slug = "ncku_2005_basemap"),
    list(year = "2008", label = "Thesis map",       slug = "ncku_2008_thesis")
  ),
  "UTS / Research Assistant" = list(
    list(year = "2016", label = "3D model — ArcGIS Desktop", slug = "uts_2016_arcgis3d"),
    list(year = "2024", label = "3D model — QGIS",           slug = "uts_2024_qgis3d"),
    list(year = "2023", label = "Flood risk analysis",       slug = "uts_2023_floodrisk")
  ),
  "SGS Economics and Planning" = list(
    list(year = "2014", label = "Project map", slug = "sgs_2014_project")
  ),
  "TomTom" = list(
    list(year = "2017", label = "Heavy vehicle gap analysis", slug = "tomtom_2017_heavyvehicle")
  ),
  "DSpark (Optus)" = list(
    list(year = "2020", label = "Project map", slug = "dspark_2020_project"),
    list(year = "2023", label = "ITS project", slug = "dspark_2023_its")
  ),
  "City of Gold Coast" = list(
    list(year = "2024", label = "Project map", slug = "goldcoast_2024_project")
  )
)

gis_map_gallery_html <- function(org) {
  maps <- career_maps[[org]]
  if (is.null(maps)) return("")
  thumbs <- paste(lapply(maps, function(m) {
    paste0(
      "<a href='career_gis_maps/full/", m$slug, ".jpg' target='_blank' rel='noopener' ",
      "title='", m$year, " · ", m$label, "' ",
      "style='display:block;width:52px;height:36px;border-radius:4px;overflow:hidden;",
      "border:1px solid rgba(255,255,255,0.15);flex-shrink:0;'>",
      "<img src='career_gis_maps/thumbs/", m$slug, ".jpg' loading='lazy' ",
      "style='width:100%;height:100%;object-fit:cover;display:block;' ",
      "alt='", m$year, " ", m$label, "'>",
      "</a>"
    )
  }), collapse = "")
  paste0(
    "<div style='margin-top:10px;padding-top:10px;border-top:1px solid rgba(255,255,255,0.08);'>",
    "<div style='font-size:9px;color:#777;text-transform:uppercase;",
    "letter-spacing:0.05em;margin-bottom:6px;'>Maps from this role</div>",
    "<div style='display:flex;flex-wrap:wrap;gap:5px;'>", thumbs, "</div>",
    "</div>"
  )
}

locations <- locations |>
  mutate(gallery_html = sapply(org, gis_map_gallery_html))

# ── Popup HTML (shown on click) ───────────────────────────────────────────────
locations <- locations |>
  mutate(popup_html = paste0(
    "<div style='font-family:system-ui,sans-serif;max-width:260px;",
    "background:#1e1e24;border-radius:8px;padding:12px 14px;'>",
    "<div style='font-size:10px;font-weight:600;text-transform:uppercase;",
    "letter-spacing:0.06em;color:", colour, ";margin-bottom:5px;'>",
    industry, " · ", period, "</div>",
    "<div style='font-size:14px;font-weight:600;color:#f0f0f0;margin-bottom:2px;'>",
    org, "</div>",
    "<div style='font-size:12px;color:#aaa;margin-bottom:4px;'>", role, "</div>",
    "<div style='font-size:11px;color:#666;margin-bottom:",
    ifelse(has_fieldwork, "10px", "0"), ";'>", city, "</div>",
    ifelse(has_fieldwork,
      paste0(
        "<a href='https://wilsonyungsh.github.io/interactive/Map15_fieldtrips.html' ",
        "target='_blank' rel='noopener' ",
        "style='display:inline-block;font-size:11px;font-family:monospace;",
        "padding:4px 10px;border-radius:4px;background:#B5925A;color:#fff;",
        "text-decoration:none;'>",
        "🗺 View fieldwork footprint →</a>"
      ),
      ""
    ),
    gallery_html,
    "</div>"
  ))

# ── Build sf objects ──────────────────────────────────────────────────────────

# Points sf
pts_sf <- st_as_sf(locations, coords = c("lng", "lat"), crs = 4326)

# Arcs are no longer drawn as a MapLibre line layer — MapLibre lines are
# flat (no z-height), so however curved they look from above, they never
# read as 3D the way mapdeck's (deck.gl) ArcLayer does. Real 3D arcs are
# added below via deck.gl's ArcLayer, interleaved on top of this MapLibre
# map (same underlying tech mapdeck uses). See the onRender block.

# ── Build map ─────────────────────────────────────────────────────────────────
map <- maplibre(
  style   = carto_style("dark-matter"),  # dark basemap
  center  = c(145, -25),
  zoom    = 3.5,
  pitch   = 0,
  bearing = 0
) |>
  # Halo circles
  add_circle_layer(
    id                  = "pts_halo",
    source              = pts_sf,
    circle_radius       = 14,
    circle_color        = list("get", "colour"),
    circle_opacity      = 0.15,
    circle_stroke_width = 0
  ) |>
  # Main circles — tooltip on hover, popup on click
  add_circle_layer(
    id                  = "pts_layer",
    source              = pts_sf,
    circle_radius       = 7,
    circle_color        = list("get", "colour"),
    circle_opacity      = 0.9,
    circle_stroke_width = 1.5,
    circle_stroke_color = "#ffffff",
    popup               = "popup_html",
    hover_options       = list(circle_radius = 10, circle_opacity = 1)
  ) |>
  # Period labels below each dot — light text for dark basemap
  add_symbol_layer(
    id          = "labels_layer",
    source      = pts_sf,
    text_field  = list("get", "period"),
    text_size   = 10,
    text_color  = "#cccccc",
    text_offset = list(0, 1.4),
    text_anchor = "top"
  )

# ── Legend HTML injected via onRender ────────────────────────────────────────
legend_html <- paste0(
  "<div id='career-legend' style='",
  "position:absolute; bottom:24px; left:12px; z-index:999;",
  "background:rgba(20,20,28,0.88); border:1px solid rgba(255,255,255,0.08);",
  "border-radius:8px; padding:10px 14px; font-family:system-ui,sans-serif;",
  "font-size:11px; line-height:1.9; box-shadow:0 2px 12px rgba(0,0,0,0.4);'>",
  "<div style='font-weight:600; font-size:12px; margin-bottom:6px; color:#e0e0e0;'>",
  "Industry</div>",
  paste(
    mapply(function(ind, col) {
      paste0(
        "<div style='display:flex;align-items:center;gap:7px;'>",
        "<span style='width:9px;height:9px;border-radius:50%;flex-shrink:0;",
        "background:", col, ";display:inline-block;'></span>",
        "<span style='color:#aaa'>", ind, "</span></div>"
      )
    },
    names(industry_colours), industry_colours
    ),
    collapse = ""
  ),
  "</div>"
)

# ── Build logo image + symbol data for onRender injection ────────────────────
# Serialise the logo manifest as a JS array literal
logo_manifest_js <- paste0(
  "[",
  paste(
    mapply(function(key, url) {
      paste0('{"key":"', key, '","url":"', url, '"}')
    },
    locations$logo_key,
    locations$logo_url
    ),
    collapse = ","
  ),
  "]"
)

# ── Tour control HTML (transport controls + story-card caption) ─────────────
# Full transport controls instead of a single play/stop toggle — prev/next
# step through stops manually (handy for jumping straight to one with a
# photo), pause holds position instead of flying back to the overview, and
# restart resets to the first stop. The caption is a card that can
# optionally hold a photo on top (hidden by default, shown only when a stop
# has one) with the existing text underneath — stops without a photo look
# exactly as before.
tour_control_html <- paste0(
  "<div id='career-tour' style='",
  "position:absolute; top:12px; right:12px; z-index:999;",
  "display:flex; flex-direction:column; align-items:flex-end; gap:6px;'>",
  "<div id='tour-controls' style='display:flex; align-items:center; gap:5px;'>",
  "<button id='tour-prev' title='Previous stop' style='",
  "font-family:system-ui,sans-serif; font-size:13px; width:28px; height:28px;",
  "border-radius:50%; border:1.5px solid #2B5F8E; background:#e8f0f8;",
  "color:#2B5F8E; cursor:pointer; padding:0;'>⏮</button>",
  "<button id='tour-btn' style='",
  "font-family:system-ui,sans-serif; font-size:12px; font-weight:600;",
  "padding:7px 14px; border-radius:100px; border:1.5px solid #2B5F8E;",
  "background:#e8f0f8; color:#2B5F8E; cursor:pointer; white-space:nowrap;'>",
  "▶ Play career tour</button>",
  "<button id='tour-next' title='Next stop' style='",
  "font-family:system-ui,sans-serif; font-size:13px; width:28px; height:28px;",
  "border-radius:50%; border:1.5px solid #2B5F8E; background:#e8f0f8;",
  "color:#2B5F8E; cursor:pointer; padding:0;'>⏭</button>",
  "<button id='tour-restart' title='Restart' style='",
  "font-family:system-ui,sans-serif; font-size:13px; width:28px; height:28px;",
  "border-radius:50%; border:1.5px solid #2B5F8E; background:#e8f0f8;",
  "color:#2B5F8E; cursor:pointer; padding:0;'>↺</button>",
  "</div>",
  "<div id='tour-speed-wrap' style='",
  "display:flex; align-items:center; gap:6px; background:rgba(20,20,28,0.88);",
  "border:1px solid rgba(255,255,255,0.08); border-radius:100px;",
  "padding:5px 12px; box-shadow:0 2px 12px rgba(0,0,0,0.4);'>",
  "<span style='font-family:system-ui,sans-serif; font-size:10px; color:#aaa; white-space:nowrap;'>Speed</span>",
  "<input id='tour-speed' type='range' min='0.1' max='2.5' step='0.1' value='1' ",
  "style='width:90px; accent-color:#7BB8F0; cursor:pointer;'>",
  "<span id='tour-speed-label' style='font-family:monospace; font-size:10px; color:#e0e0e0; width:28px;'>1.0×</span>",
  "</div>",
  "<div id='tour-caption' style='",
  "opacity:0; transition:opacity 0.3s; width:260px;",
  "background:rgba(20,20,28,0.88); border:1px solid rgba(255,255,255,0.08);",
  "border-radius:10px; overflow:hidden; box-shadow:0 2px 12px rgba(0,0,0,0.4);'>",
  "<img id='tour-caption-photo' style='display:none; width:100%; height:150px; object-fit:cover;'>",
  "<div id='tour-caption-text' style='padding:8px 12px; text-align:right;",
  "font-family:system-ui,sans-serif; font-size:11px; color:#e0e0e0;'></div>",
  "</div>",
  "</div>"
)

# Serialise the ordered tour stops (locations are already chronological by id)
tour_manifest_js <- paste0(
  "[",
  paste(
    mapply(function(lng, lat, org, period, photo) {
      photo_field <- if (is.na(photo)) "null" else paste0('"', photo, '"')
      paste0('{"lng":', lng, ',"lat":', lat, ',"org":"', org, '","period":"', period,
             '","photo":', photo_field, '}')
    },
    locations$lng, locations$lat, locations$org, locations$period, locations$photo
    ),
    collapse = ","
  ),
  "]"
)

# Serialise consecutive-pair arcs for deck.gl's ArcLayer — one {from,to} per
# hop, in the same chronological order as the tour.
deck_arc_manifest_js <- paste0(
  "[",
  paste(
    sapply(seq_len(nrow(locations) - 1), function(i) {
      paste0(
        '{"from":[', locations$lng[i],     ",", locations$lat[i],     "],",
        '"to":[',    locations$lng[i + 1], ",", locations$lat[i + 1], "]}"
      )
    }),
    collapse = ","
  ),
  "]"
)

map <- map |>
  htmlwidgets::onRender(paste0(
    "function(el, x) {",

    # ── Inject legend ──
    "  var leg = document.createElement('div');",
    "  leg.innerHTML = `", legend_html, "`;",
    "  el.appendChild(leg.firstChild);",

    # ── Inject tour control ──
    "  var tourCtrl = document.createElement('div');",
    "  tourCtrl.innerHTML = `", tour_control_html, "`;",
    "  el.appendChild(tourCtrl.firstChild);",

    # ── Wait for map style to load, then load logos + add symbol layer ──
    "  var map = this;",
    "  var logos = ", logo_manifest_js, ";",
    "  var tourStops = ", tour_manifest_js, ";",
    "  var deckArcs = ", deck_arc_manifest_js, ";",
    "  var overview = { center: [145, -25], zoom: 3.5, pitch: 0, bearing: 0 };",

    # We need the actual MapLibre map instance — mapgl stores it on the widget
    "  function getMLMap(el) {",
    "    var keys = Object.keys(el);",
    "    for (var i = 0; i < keys.length; i++) {",
    "      var v = el[keys[i]];",
    "      if (v && typeof v.loadImage === 'function') return v;",
    "    }",
    "    return null;",
    "  }",

    "  function addLogoLayer(mlmap) {",
    "    var loaded = 0;",
    # This build of MapLibre GL JS's Map#loadImage(url) is Promise-based —
    # it takes ONE argument and resolves { data: <image> }. It does NOT
    # accept a (err, img) callback as a second argument (that's the old
    # Mapbox GL JS style). Passing one silently does nothing: the call still
    # "succeeds" but the callback is never invoked, so `loaded` never
    # reaches logos.length and addLayer() below never runs — no error, no
    # image, nothing rendered. Confirmed by a live in-browser probe before
    # fixing (loadImage's returned promise just sat unused).
    "    function afterEachLogo() {",
    "      loaded++;",
    "      if (loaded !== logos.length) return;",
    "      var ptsStyleLayer = mlmap.getLayer('pts_layer');",
    "      var srcName = ptsStyleLayer ? ptsStyleLayer.source : null;",
    "      if (!srcName) {",
    "        var sources = mlmap.getStyle().sources;",
    "        var keys = Object.keys(sources);",
    "        for (var s=0;s<keys.length;s++){",
    "          if(sources[keys[s]].type==='geojson'){srcName=keys[s];break;}",
    "        }",
    "      }",
    "      mlmap.addLayer({",
    "        id: 'logo_layer',",
    "        type: 'symbol',",
    "        source: srcName,",
    "        layout: {",
    "          'icon-image': ['get', 'logo_key'],",
    "          'icon-size': 0.28,",
    "          'icon-allow-overlap': true,",
    "          'icon-ignore-placement': true",
    "        }",
    "      });",
    "    }",
    "    logos.forEach(function(logo) {",
    "      mlmap.loadImage(logo.url).then(function(res) {",
    "        var img = res && res.data;",
    "        if (img && !mlmap.hasImage(logo.key)) mlmap.addImage(logo.key, img);",
    "      }).catch(function() {}).then(afterEachLogo);",
    "    });",
    "  }",

    # ── Fly-through tour: visit each career stop in chronological order.
    # Full transport-control state machine. idx = the stop we're at (or
    # flying to). flying = auto-advance is on. started = we've flown to a
    # stop at least once (controls the button's "Play" vs "Resume" label).
    # Pausing never flies back to the overview any more — it just holds
    # position wherever it is. ──
    "  function wireTourButton(mlmap) {",
    "    var btn = document.getElementById('tour-btn');",
    "    var prevBtn = document.getElementById('tour-prev');",
    "    var nextBtn = document.getElementById('tour-next');",
    "    var restartBtn = document.getElementById('tour-restart');",
    "    var caption = document.getElementById('tour-caption');",
    "    var captionPhoto = document.getElementById('tour-caption-photo');",
    "    var captionText = document.getElementById('tour-caption-text');",
    "    var speedInput = document.getElementById('tour-speed');",
    "    var speedLabel = document.getElementById('tour-speed-label');",
    "    if (!btn || btn.dataset.wired) return;",
    "    btn.dataset.wired = '1';",
    "    var idx = 0;",
    "    var flying = false;",
    "    var started = false;",
    "    var timer = null;",
    # Speed slider: 0.1x (very slow) to 2.5x (fast overview). Read fresh
    # each hop so dragging mid-tour takes effect on the next leg
    # immediately, rather than only at the next play click.
    "    function getSpeed() { return speedInput ? parseFloat(speedInput.value) : 1; }",
    "    if (speedInput) {",
    "      speedInput.addEventListener('input', function() {",
    "        speedLabel.textContent = getSpeed().toFixed(1) + '×';",
    "      });",
    "    }",
    "    function updateLabel() {",
    "      btn.textContent = flying ? '⏸ Pause' : (started ? '▶ Resume' : '▶ Play career tour');",
    "    }",
    "    function showStop(i) {",
    "      var s = tourStops[i];",
    "      caption.style.opacity = 1;",
    "      if (s.photo) {",
    "        captionPhoto.src = s.photo;",
    "        captionPhoto.style.display = 'block';",
    "      } else {",
    "        captionPhoto.style.display = 'none';",
    "        captionPhoto.removeAttribute('src');",
    "      }",
    "      captionText.innerHTML = '<b>' + (i + 1) + ' / ' + tourStops.length + '</b> · ' + s.org + ' · ' + s.period;",
    # pitch 55 — steep enough to feel like a real fly-in and show the deck.gl
    # arc's elevation as it comes into each stop, but still under MapLibre's
    # default 60° max so the horizon doesn't dominate the frame.
    "      mlmap.flyTo({ center: [s.lng, s.lat], zoom: 15.5, pitch: 55, bearing: 0, duration: Math.round(1800 / getSpeed()), essential: true });",
    "      started = true;",
    "    }",
    "    function scheduleNext() {",
    "      if (timer) clearTimeout(timer);",
    "      timer = setTimeout(function() {",
    "        if (idx < tourStops.length - 1) {",
    "          idx++;",
    "          showStop(idx);",
    "          scheduleNext();",
    "        } else {",
    "          flying = false;",
    "          updateLabel();",
    "        }",
    "      }, Math.round(3200 / getSpeed()));",
    "    }",
    "    function play() {",
    "      flying = true;",
    "      updateLabel();",
    "      if (!started) showStop(idx);",
    "      scheduleNext();",
    "    }",
    "    function pause() {",
    "      flying = false;",
    "      if (timer) { clearTimeout(timer); timer = null; }",
    "      updateLabel();",
    "    }",
    "    function step(delta) {",
    "      var next = idx + delta;",
    "      if (next < 0 || next > tourStops.length - 1) return;",
    "      idx = next;",
    "      showStop(idx);",
    "      if (flying) scheduleNext();",
    "    }",
    "    btn.addEventListener('click', function() { flying ? pause() : play(); });",
    "    if (prevBtn) prevBtn.addEventListener('click', function() { step(-1); });",
    "    if (nextBtn) nextBtn.addEventListener('click', function() { step(1); });",
    "    if (restartBtn) restartBtn.addEventListener('click', function() {",
    "      idx = 0;",
    "      started = false;",
    "      pause();",
    "      play();",
    "    });",
    "  }",

    "  function tryAdd() {",
    "    var mlmap = getMLMap(el);",
    "    if (mlmap && mlmap.isStyleLoaded()) {",
    # MapLibre auto-switches to a 3D globe projection at low zoom levels
    # (this map's initial zoom 3.5 falls inside that range). deck.gl's
    # overlay only tracks flat Mercator, so the ArcLayer silently fails to
    # render (or renders somewhere invisible) whenever the globe is active —
    # confirmed live: arcs appeared as soon as the map was zoomed in past
    # the globe threshold, and were invisible at the default overview.
    # Forcing flat projection keeps it consistent with the rest of the
    # design (halo circles, labels, logos) which all assume flat Mercator.
    "      if (mlmap.setProjection) mlmap.setProjection({ type: 'mercator' });",
    "      addLogoLayer(mlmap);",
    "      wireTourButton(mlmap);",
    "    } else {",
    "      setTimeout(tryAdd, 200);",
    "    }",
    "  }",
    "  tryAdd();",

    # ── Real 3D arcs via deck.gl (the same rendering engine mapdeck/R uses),
    # interleaved on top of this MapLibre map. MapLibre's own line layer has
    # no z-height — however curved a line looks from above, it stays flat —
    # so it can never read as 3D the way deck.gl's ArcLayer does (true
    # elevation + per-vertex shading + source/target colour gradient).
    # deck.gl is loaded from a CDN at runtime (not bundled by htmlwidgets),
    # so this waits for both the script and the map style before adding it.
    "  var deckScriptEl = document.createElement('script');",
    "  deckScriptEl.src = 'https://unpkg.com/deck.gl@9.4.0/dist.min.js';",
    "  document.head.appendChild(deckScriptEl);",
    "  function tryAddDeckArcs() {",
    "    var mlmap = getMLMap(el);",
    "    if (!window.deck || !mlmap || !mlmap.isStyleLoaded()) {",
    "      setTimeout(tryAddDeckArcs, 200);",
    "      return;",
    "    }",
    "    var arcLayer = new deck.ArcLayer({",
    "      id: 'career-arcs',",
    "      data: deckArcs,",
    "      getSourcePosition: function(d) { return d.from; },",
    "      getTargetPosition: function(d) { return d.to; },",
    "      getSourceColor: [91, 155, 213, 255],",
    "      getTargetColor: [140, 210, 255, 255],",
    "      getWidth: 4,",
    "      widthMinPixels: 2.5,",
    "      getHeight: 0.6,",
    "      greatCircle: true",
    "    });",
    "    mlmap.addControl(new deck.MapboxOverlay({ layers: [arcLayer] }));",
    "  }",
    "  tryAddDeckArcs();",
    "}"
  ))

# ── Save ──────────────────────────────────────────────────────────────────────
htmlwidgets::saveWidget(
  map,
  file            = "career_map.html",
  selfcontained   = TRUE,
  title           = "Wilson Yung — Career Map"
)

message("✓ career_map.html saved — embed in index.html via:")
message('  <iframe src="career_map.html" width="100%" height="480"')
message('          style="border:none; border-radius:8px;"></iframe>')
