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
  id       = 1:10,
  org      = c(
    "National Cheng Kung University",
    "Tamkang University",
    "UTS / Research Assistant",
    "Appen Butler Hill",
    "SGS Economics and Planning",
    "TomTom",
    "Sydney Water",
    "Transport for NSW",
    "DSpark (Optus)",
    "Brisbane City Council"
  ),
  role     = c(
    "Urban Planning degree (B + M)",
    "Research Planner, Water Resource Management",
    "Research Assistant + Sessional Lecturer (ongoing)",
    "Fieldwork Project Specialist",
    "GIS Researcher / Town Planner",
    "GIS Engineer → Senior Sourcing Analyst",
    "Field Service Officer",
    "Spatial Data Analyst",
    "Principal Data Science Consultant",
    "Principal Research Officer, Team Lead RMU"
  ),
  period   = c(
    "2001–2007",
    "2009–2010",
    "2012–present",
    "2013–2014",
    "2014",
    "2015–2017",
    "2015",
    "2017–2018",
    "2019–2024",
    "2025–present"
  ),
  city     = c(
    "Tainan, Taiwan(台南‧台灣)",
    "TamShui, Taiwan(淡水‧台灣)",
    "Sydney, Australia",
    "Chatswood, Sydney",
    "Sydney CBD",
    "North Ryde, Sydney",
    "Potts Hill, Sydney",
    "Sydney CBD",
    "Macquarie Park, Sydney → Brisbane",
    "Brisbane CBD"
  ),
  industry = c(
    "Education & Academia",          # NCKU
    "Water Resources",               # Tamkang — water resource policy & management
    "Education & Academia",          # UTS
    "Data & Fieldwork Services",     # Appen
    "Urban & Land Use Planning",     # SGS
    "Commercial Map Production",     # TomTom — not "GIS industry", they make commercial maps
    "Water Resources",               # Sydney Water
    "Transport & Mobility Data",     # Transport for NSW
    "Transport & Mobility Data",     # DSpark (Optus) — telco mobility data
    "Urban & Land Use Planning"      # Brisbane City Council
  ),
  lng      = c(
    120.2156431519289,    # NCKU — 都計系館 (Dept. of Urban Planning building)
    121.44592677983286,   # Tamkang New Taipei
    151.2002,             # UTS Sydney
    151.1803,             # Chatswood (Appen)
    151.20936716143243,   # SGSEP Sydney CBD (corrected)
    151.14550704742223,   # TomTom Lane Cove (corrected)
    151.0338,             # Sydney Water Potts Hill
    151.20629833027127,   # TfNSW Sydney CBD (corrected)
    153.0111418034162,    # DSpark Brisbane (corrected)
    153.02256254709644    # Brisbane City Council CBD
  ),
  lat      = c(
    23.000938960734327,   # NCKU — 都計系館 (Dept. of Urban Planning building)
    25.17406363863662,    # Tamkang New Taipei
    -33.8833,             # UTS Sydney
    -33.7969,             # Chatswood (Appen)
    -33.88593930086862,   # SGSEP (corrected)
    -33.79837208739991,   # TomTom (corrected)
    -33.9082,             # Sydney Water Potts Hill
    -33.88041851325041,   # TfNSW (corrected)
    -27.474321855338705,  # DSpark Brisbane (corrected)
    -27.470776856892282   # Brisbane City Council
  ),
  has_fieldwork = c(
    FALSE, FALSE, FALSE,
    TRUE,   # Appen — links to fieldtrip map
    FALSE, FALSE, FALSE, FALSE, FALSE, FALSE
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
    "career_logos/tku.png",
    "career_logos/uts.png",
    "career_logos/appen.png",
    "career_logos/sgs.png",
    "career_logos/tomtom.png",
    "career_logos/sydwater.png",
    "career_logos/tfnsw.png",
    "career_logos/optus.png",
    "career_logos/bcc.png"
  ),
  # Unique image key per dot (used as MapLibre sprite name)
  logo_key = c(
    "logo_ncku", "logo_tku", "logo_uts", "logo_appen", "logo_sgs",
    "logo_tomtom", "logo_sydwater", "logo_tfnsw", "logo_optus", "logo_bcc"
  )
  )

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
    "</div>"
  ))

# ── Build sf objects ──────────────────────────────────────────────────────────

# Points sf
pts_sf <- st_as_sf(locations, coords = c("lng", "lat"), crs = 4326)

# Arc lines sf — one curved linestring per consecutive pair.
# Curve is a quadratic Bezier: start/end at the two points, control point
# offset perpendicular to the straight line by `bulge` (fraction of the
# lng/lat span), sampled into `n` vertices so it renders as a smooth arc
# instead of a straight segment.
make_arc <- function(lng1, lat1, lng2, lat2, bulge = 0.15, n = 40) {
  dx <- lng2 - lng1
  dy <- lat2 - lat1
  perp_x <- -dy
  perp_y <- dx
  ctrl_x <- (lng1 + lng2) / 2 + perp_x * bulge
  ctrl_y <- (lat1 + lat2) / 2 + perp_y * bulge
  t <- seq(0, 1, length.out = n)
  x <- (1 - t)^2 * lng1 + 2 * (1 - t) * t * ctrl_x + t^2 * lng2
  y <- (1 - t)^2 * lat1 + 2 * (1 - t) * t * ctrl_y + t^2 * lat2
  cbind(x, y)
}

arc_lines <- lapply(seq_len(nrow(locations) - 1), function(i) {
  st_linestring(make_arc(
    locations$lng[i],     locations$lat[i],
    locations$lng[i + 1], locations$lat[i + 1]
  ))
})
arcs_sf <- st_sf(
  seq      = seq_len(nrow(locations) - 1),
  geometry = st_sfc(arc_lines, crs = 4326)
)

# ── Build map ─────────────────────────────────────────────────────────────────
map <- maplibre(
  style   = carto_style("dark-matter"),  # dark basemap
  center  = c(145, -25),
  zoom    = 3.5,
  pitch   = 0,
  bearing = 0
) |>
  # Arc glow (wide, low opacity — gives neon glow effect on dark)
  add_line_layer(
    id           = "arcs_glow",
    source       = arcs_sf,
    line_color   = "#5B9BD5",
    line_width   = 6,
    line_opacity = 0.18,
    line_blur    = 4
  ) |>
  # Arc core line
  add_line_layer(
    id             = "arcs_layer",
    source         = arcs_sf,
    line_color     = "#7BB8F0",
    line_width     = 1.8,
    line_opacity   = 0.75,
    line_dasharray = list(4, 3)
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

# ── Tour control HTML (button + "now showing" caption) ───────────────────────
tour_control_html <- paste0(
  "<div id='career-tour' style='",
  "position:absolute; top:12px; right:12px; z-index:999;",
  "display:flex; flex-direction:column; align-items:flex-end; gap:6px;'>",
  "<button id='tour-btn' style='",
  "font-family:system-ui,sans-serif; font-size:12px; font-weight:600;",
  "padding:7px 14px; border-radius:100px; border:1.5px solid #2B5F8E;",
  "background:#e8f0f8; color:#2B5F8E; cursor:pointer;'>",
  "▶ Play career tour</button>",
  "<div id='tour-caption' style='",
  "opacity:0; transition:opacity 0.3s; max-width:260px; text-align:right;",
  "background:rgba(20,20,28,0.88); border:1px solid rgba(255,255,255,0.08);",
  "border-radius:8px; padding:6px 12px; font-family:system-ui,sans-serif;",
  "font-size:11px; color:#e0e0e0; box-shadow:0 2px 12px rgba(0,0,0,0.4);'></div>",
  "</div>"
)

# Serialise the ordered tour stops (locations are already chronological by id)
tour_manifest_js <- paste0(
  "[",
  paste(
    mapply(function(lng, lat, org, period) {
      paste0('{"lng":', lng, ',"lat":', lat, ',"org":"', org, '","period":"', period, '"}')
    },
    locations$lng, locations$lat, locations$org, locations$period
    ),
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
    "    logos.forEach(function(logo) {",
    "      mlmap.loadImage(logo.url, function(err, img) {",
    "        if (!err && img) {",
    "          if (!mlmap.hasImage(logo.key)) mlmap.addImage(logo.key, img);",
    "        }",
    "        loaded++;",
    "        if (loaded === logos.length) {",
    # All images attempted — add symbol layer on top. Ask MapLibre what
    # source the pts_layer circle layer is actually bound to instead of
    # guessing a name — mapgl auto-generates the internal source id and it
    # does NOT reuse the layer's own id, so the previous 'pts_layer' guess
    # (and its key-order fallback) silently attached the icons to the wrong
    # source, meaning icon-image resolved to nothing and nothing rendered.
    "          var ptsStyleLayer = mlmap.getLayer('pts_layer');",
    "          var srcName = ptsStyleLayer ? ptsStyleLayer.source : null;",
    "          if (!srcName) {",
    "            var sources = mlmap.getStyle().sources;",
    "            var keys = Object.keys(sources);",
    "            for (var s=0;s<keys.length;s++){",
    "              if(sources[keys[s]].type==='geojson'){srcName=keys[s];break;}",
    "            }",
    "          }",
    "          mlmap.addLayer({",
    "            id: 'logo_layer',",
    "            type: 'symbol',",
    "            source: srcName,",
    "            layout: {",
    "              'icon-image': ['get', 'logo_key'],",
    "              'icon-size': 0.28,",
    "              'icon-allow-overlap': true,",
    "              'icon-ignore-placement': true",
    "            }",
    "          });",
    "        }",
    "      });",
    "    });",
    "  }",

    # ── Fly-through tour: visit each career stop in chronological order.
    # The button toggles between play/stop — clicking while touring cancels
    # the tour immediately (stops the in-flight animation and flies back to
    # the overview) instead of waiting for it to finish. ──
    "  function wireTourButton(mlmap) {",
    "    var btn = document.getElementById('tour-btn');",
    "    var caption = document.getElementById('tour-caption');",
    "    if (!btn || btn.dataset.wired) return;",
    "    btn.dataset.wired = '1';",
    "    var flying = false;",
    "    var timer = null;",
    "    function stopTour() {",
    "      if (timer) { clearTimeout(timer); timer = null; }",
    "      flying = false;",
    "      btn.textContent = '▶ Play career tour';",
    "      caption.style.opacity = 0;",
    "      mlmap.stop();",
    "      mlmap.flyTo({ center: overview.center, zoom: overview.zoom, pitch: overview.pitch, bearing: overview.bearing, duration: 1500, essential: true });",
    "    }",
    "    function playTour() {",
    "      flying = true;",
    "      btn.textContent = '⏹ Stop tour';",
    "      var i = 0;",
    "      function next() {",
    "        if (!flying) return;",
    "        if (i >= tourStops.length) { stopTour(); return; }",
    "        var s = tourStops[i];",
    "        caption.style.opacity = 1;",
    "        caption.innerHTML = '<b>' + (i + 1) + ' / ' + tourStops.length + '</b> · ' + s.org + ' · ' + s.period;",
    "        mlmap.flyTo({ center: [s.lng, s.lat], zoom: 15.5, pitch: 45, bearing: 0, duration: 1800, essential: true });",
    "        i++;",
    "        timer = setTimeout(next, 3200);",
    "      }",
    "      next();",
    "    }",
    "    btn.addEventListener('click', function() {",
    "      if (flying) { stopTour(); } else { playTour(); }",
    "    });",
    "  }",

    "  function tryAdd() {",
    "    var mlmap = getMLMap(el);",
    "    if (mlmap && mlmap.isStyleLoaded()) {",
    "      addLogoLayer(mlmap);",
    "      wireTourButton(mlmap);",
    "    } else {",
    "      setTimeout(tryAdd, 200);",
    "    }",
    "  }",
    "  tryAdd();",
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
