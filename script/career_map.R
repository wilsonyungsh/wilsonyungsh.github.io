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
  chapter  = c(
    "Education",
    "Early career",
    "Academia",
    "Fieldwork",
    "Planning",
    "GIS industry",
    "GIS industry",
    "Transport",
    "Mobility data pivot",
    "Current"
  ),
  lng      = c(
    120.21577501445299,   # NCKU Tainan (corrected)
    121.4628,             # Tamkang New Taipei
    151.2002,             # UTS Sydney
    151.1803,             # Chatswood (Appen)
    151.20936716143243,   # SGSEP Sydney CBD (corrected)
    151.14550704742223,   # TomTom Lane Cove (corrected)
    151.0338,             # Sydney Water Potts Hill
    151.20629833027127,   # TfNSW Sydney CBD (corrected)
    153.0111418034162,    # DSpark Brisbane (corrected)
    153.0260              # Brisbane City Council CBD
  ),
  lat      = c(
    22.998176618344687,   # NCKU Tainan — northern hemisphere
    25.1798,              # Tamkang New Taipei
    -33.8833,             # UTS Sydney
    -33.7969,             # Chatswood (Appen)
    -33.88593930086862,   # SGSEP (corrected)
    -33.79837208739991,   # TomTom (corrected)
    -33.9082,             # Sydney Water Potts Hill
    -33.88041851325041,   # TfNSW (corrected)
    -27.474321855338705,  # DSpark Brisbane (corrected)
    -27.4705              # Brisbane City Council
  ),
  has_fieldwork = c(
    FALSE, FALSE, FALSE,
    TRUE,   # Appen — links to fieldtrip map
    FALSE, FALSE, FALSE, FALSE, FALSE, FALSE
  ),
  stringsAsFactors = FALSE
)

# Chapter colour palette (hex) — warm for pivots, neutral for others
chapter_colours <- c(
  "Education"          = "#638B9E",
  "Early career"       = "#7A9E87",
  "Academia"           = "#8E7DB5",
  "Fieldwork"          = "#B5925A",
  "Planning"           = "#6B9E9E",
  "GIS industry"       = "#5A7FA8",
  "Transport"          = "#4A8C6F",
  "Mobility data pivot" = "#C4783A",  # amber — the pivot moment
  "Current"            = "#2D6FA3"   # strong blue — present day
)

locations <- locations |>
  mutate(colour = chapter_colours[chapter])

# ── Logo URLs ─────────────────────────────────────────────────────────────────
# Simple Icons CDN (white on transparent — good on dark basemap) for known brands.
# Google favicon service as fallback for others.
locations <- locations |>
  mutate(logo_url = c(
    # NCKU — favicon from ncku.edu.tw
    "https://www.google.com/s2/favicons?sz=64&domain=ncku.edu.tw",
    # Tamkang University
    "https://www.google.com/s2/favicons?sz=64&domain=tku.edu.tw",
    # UTS
    "https://www.google.com/s2/favicons?sz=64&domain=uts.edu.au",
    # Appen
    "https://www.google.com/s2/favicons?sz=64&domain=appen.com",
    # SGS Economics and Planning
    "https://www.google.com/s2/favicons?sz=64&domain=sgsep.com.au",
    # TomTom — Simple Icons, white
    "https://cdn.simpleicons.org/tomtom/ffffff",
    # Sydney Water
    "https://www.google.com/s2/favicons?sz=64&domain=sydneywater.com.au",
    # Transport for NSW
    "https://www.google.com/s2/favicons?sz=64&domain=transport.nsw.gov.au",
    # DSpark / Optus — Simple Icons, white
    "https://cdn.simpleicons.org/optus/ffffff",
    # Brisbane City Council
    "https://www.google.com/s2/favicons?sz=64&domain=brisbane.qld.gov.au"
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
    chapter, " · ", period, "</div>",
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

# Arc lines sf — one linestring per consecutive pair
arc_lines <- lapply(seq_len(nrow(locations) - 1), function(i) {
  st_linestring(matrix(
    c(locations$lng[i],   locations$lat[i],
      locations$lng[i + 1], locations$lat[i + 1]),
    ncol = 2, byrow = TRUE
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
  "Career chapters</div>",
  paste(
    mapply(function(ch, col) {
      paste0(
        "<div style='display:flex;align-items:center;gap:7px;'>",
        "<span style='width:9px;height:9px;border-radius:50%;flex-shrink:0;",
        "background:", col, ";display:inline-block;'></span>",
        "<span style='color:#aaa'>", ch, "</span></div>"
      )
    },
    names(chapter_colours), chapter_colours
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

map <- map |>
  htmlwidgets::onRender(paste0(
    "function(el, x) {",

    # ── Inject legend ──
    "  var leg = document.createElement('div');",
    "  leg.innerHTML = `", legend_html, "`;",
    "  el.appendChild(leg.firstChild);",

    # ── Wait for map style to load, then load logos + add symbol layer ──
    "  var map = this;",
    "  var logos = ", logo_manifest_js, ";",

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
    # All images attempted — add symbol layer on top.
    # mapgl names the geojson source after the layer id when an sf object
    # is passed directly, so pts_layer source = 'pts_layer'.
    "          var srcName = 'pts_layer';",
    "          var sources = mlmap.getStyle().sources;",
    "          if (!sources[srcName]) {",
    # fallback: find any geojson source that has our data
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
    "              'icon-size': 0.45,",
    "              'icon-allow-overlap': true,",
    "              'icon-ignore-placement': true",
    "            }",
    "          });",
    "        }",
    "      });",
    "    });",
    "  }",

    "  function tryAdd() {",
    "    var mlmap = getMLMap(el);",
    "    if (mlmap && mlmap.isStyleLoaded()) {",
    "      addLogoLayer(mlmap);",
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
