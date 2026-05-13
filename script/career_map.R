# career_map.R
# Interactive career map for Wilson Yung's portfolio website
# Generates a self-contained HTML file using mapgl (MapLibre GL)
# Output: career_map.html — embed in index.html via <iframe>

library(mapgl)
library(htmlwidgets)
library(dplyr)

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
    "2002–2010",
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
    "Tainan, Taiwan",
    "New Taipei City, Taiwan",
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
    120.2269,   # NCKU Tainan
    121.4628,   # Tamkang New Taipei
    151.2002,   # UTS Sydney
    151.1803,   # Chatswood
    151.2093,   # Sydney CBD
    151.1218,   # North Ryde
    151.0338,   # Potts Hill
    151.2093,   # Sydney CBD
    151.1218,   # Macquarie Park (DSpark HQ; BNE work later)
    153.0260    # Brisbane CBD
  ),
  lat      = c(
    -22.9970,
    25.1798,    # NOTE: northern hemisphere, positive lat
    -33.8833,
    -33.7969,
    -33.8688,
    -33.7969,
    -33.9082,
    -33.8688,
    -33.7730,
    -27.4705
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

locations
# ── Popup HTML (shown on click) ───────────────────────────────────────────────
locations <- locations |>
  mutate(popup_html = paste0(
    "<div style='font-family: system-ui, sans-serif; max-width: 220px;'>",
    "<div style='font-size:11px; font-weight:600; text-transform:uppercase; ",
    "letter-spacing:0.05em; color:", colour, "; margin-bottom:4px;'>",
    chapter, " · ", period, "</div>",
    "<div style='font-size:14px; font-weight:600; color:#1a1a1a; margin-bottom:2px;'>",
    org, "</div>",
    "<div style='font-size:12px; color:#555; margin-bottom:4px;'>", role, "</div>",
    "<div style='font-size:11px; color:#888;'>", city, "</div>",
    "</div>"
  )) %>%
  sf::st_as_sf(coords = c("lng", "lat"), crs = 4326)

# ── Build map ─────────────────────────────────────────────────────────────────
map <- maplibre(
  style   = carto_style("positron"),   # clean light basemap
  center  = c(145, -25),               # rough centre of career geography
  zoom    = 3.5,
  pitch   = 0,
  bearing = 0
) |>
  # Arc lines connecting locations in chronological order
  add_source(
    id   = "career_arcs",
    type = "geojson",
    data = {
      # Build linestring features between consecutive locations
      arcs <- vector("list", nrow(locations) - 1)
      for (i in seq_len(nrow(locations) - 1)) {
        arcs[[i]] <- list(
          type = "Feature",
          properties = list(seq = i),
          geometry   = list(
            type        = "LineString",
            coordinates = list(
              c(locations$lng[i],   locations$lat[i]),
              c(locations$lng[i + 1], locations$lat[i + 1])
            )
          )
        )
      }
      list(type = "FeatureCollection", features = arcs)
    }
  ) |>
  add_line_layer(
    id           = "arcs_layer",
    source       = "career_arcs",
    line_color   = "#B0B0B0",
    line_width   = 1,
    line_opacity = 0.45,
    line_dasharray = list(3, 3)
  ) |>
  # Location circles
  add_source(
    id   = "career_pts",
    type = "geojson",
    data = {
      feats <- lapply(seq_len(nrow(locations)), function(i) {
        list(
          type       = "Feature",
          properties = as.list(locations[i, c("org", "role", "period", "city",
            "chapter", "colour", "popup_html")]),
          geometry   = list(
            type        = "Point",
            coordinates = c(locations$lng[i], locations$lat[i])
          )
        )
      })
      list(type = "FeatureCollection", features = feats)
    }
  ) |>
  add_circle_layer(
    id              = "pts_halo",
    source          = "career_pts",
    circle_radius   = 14,
    circle_color    = list("get", "colour"),
    circle_opacity  = 0.15,
    circle_stroke_width = 0
  ) |>
  add_circle_layer(
    id                   = "pts_layer",
    source               = "career_pts",
    circle_radius        = 7,
    circle_color         = list("get", "colour"),
    circle_opacity       = 0.9,
    circle_stroke_width  = 1.5,
    circle_stroke_color  = "#ffffff",
    tooltip              = "popup_html",
    hover_options        = list(circle_radius = 10, circle_opacity = 1)
  ) |>
  # Year labels next to each dot
  add_symbol_layer(
    id     = "labels_layer",
    source = "career_pts",
    text_field = list("get", "period"),
    text_size  = 10,
    text_color = "#444444",
    text_offset = list(0, 1.4),
    text_anchor = "top"
  )

# ── Legend HTML injected via onRender ────────────────────────────────────────
legend_html <- paste0(
  "<div id='career-legend' style='",
  "position:absolute; bottom:24px; left:12px; z-index:999;",
  "background:rgba(255,255,255,0.92); border-radius:8px;",
  "padding:10px 14px; font-family:system-ui,sans-serif;",
  "font-size:11px; line-height:1.8; box-shadow:0 1px 6px rgba(0,0,0,0.1);'>",
  "<div style='font-weight:600; font-size:12px; margin-bottom:6px; color:#333;'>",
  "Career chapters</div>",
  paste(
    mapply(function(ch, col) {
      paste0(
        "<div style='display:flex;align-items:center;gap:6px;'>",
        "<span style='width:10px;height:10px;border-radius:50%;",
        "background:", col, ";display:inline-block;'></span>",
        "<span style='color:#444'>", ch, "</span></div>"
      )
    },
    names(chapter_colours), chapter_colours
    ),
    collapse = ""
  ),
  "</div>"
)

map <- map |>
  htmlwidgets::onRender(paste0(
    "function(el, x) {",
    "  var leg = document.createElement('div');",
    "  leg.innerHTML = `", legend_html, "`;",
    "  el.appendChild(leg.firstChild);",
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
