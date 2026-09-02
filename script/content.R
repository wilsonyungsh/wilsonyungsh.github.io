# content.R
# ─────────────────────────────────────────────────────────────────────────────
# 所有中英文內容集中在這裡。
# 修改完後執行 build.R 即可重新產生 index.html。
# ─────────────────────────────────────────────────────────────────────────────

content <- list(

  # ── Meta ──────────────────────────────────────────────────────────────────
  meta = list(
    title_en = "Wilson Yung — Spatial Data Scientist",
    title_zh = "雍士賢 — 以資料閱讀城市，以空間描繪移動",
    description_en = "Spatial data scientist and consultant specialising in transport data, urban modelling, and open-source spatial analytics. Learning operational and domain knowledge on City scale 3D Modelling. Based in Brisbane, Australia.",
    description_zh = "空間資料科學家，專注於大眾運輸資料分析、都市成長模擬與開源空間分析。長年穿梭於資料與城市之間，透過模型、地圖與程式碼，探索人們如何生活、移動與形塑城市。現居澳洲布里斯本。"
  ),

  # ── Nav ───────────────────────────────────────────────────────────────────
  nav = list(
    expertise_en = "Expertise",   expertise_zh = "專業領域",
    career_en    = "Career",      career_zh    = "工作歷程",
    portfolio_en = "Portfolio",   portfolio_zh = "作品集",
    contact_en   = "Contact",     contact_zh   = "聯絡"
  ),

  # ── Hero ──────────────────────────────────────────────────────────────────
  hero = list(
    eyebrow_en = "Spatial Data Scientist · Brisbane, Australia",
    eyebrow_zh = "空間資料科學家 · 澳洲布里斯本",

    h1_line1_en = "Cities, Data,",
    h1_line1_zh = "都市、資料，",
    h1_em_en    = "Movement.",
    h1_em_zh    = "與流動的人群。",

    desc_en = paste(
      "End-to-end consulting across spatial analytics, transport data, urban growth modelling,",
      "and open-source data engineering. Over a decade bridging GIS, mobility data, and",
      "modern cloud-native pipelines across government and industry."
    ),
    desc_zh = paste(
      "透過空間分析、運輸資料、都市模擬與開源資料工程。",
      "將散落於城市中的資訊串連成故事，從地圖撇見人群移動的軌跡，以資料角度出發進而理解城市演變的脈絡。",
      "十餘年來持續在政府、研究與產業之間搭建橋梁，讓資料成為理解都市的一種語彙，以自身旅居經驗努力實踐。"
    ),

    # Chips — 技術標籤（左側 accent 色）
    chips_accent = c("R · Python · SQL", "PostGIS · QGIS", "Apache Spark · Sedona"),

    # Chips — 領域標籤（右側一般色）
    chips_en = c("Spatial analytics", "GTFS · Transport data", "Urban growth modelling", "Open data"),
    chips_zh = c("空間分析",           "GTFS · 大眾運輸資料",        "都市成長預測建模",            "開源資料")
  ),

  # ── Footprint map ─────────────────────────────────────────────────────────
  footprint = list(
    label_en   = "My footprint 2013–2025",
    label_zh   = "我的足跡 2013–2025",
    caption_en = "↑ Built from Google Timeline data · 30 Day Map Challenge 2025 Day 4 · R + Mapdeck",
    caption_zh = "↑ 以 Google 時間軸資料製作 · 30天地圖挑戰 2025 第4天 · R + Mapdeck",
    iframe_src = "https://wilsonyungsh.github.io/interactive/30DayMapChallenge2025/Map4_Mydata_2013-2025.html"
  ),

  # ── Expertise / domain cards ──────────────────────────────────────────────
  expertise = list(
    label_en = "What I do",
    label_zh = "領域專長",

    domains = list(
      list(
        icon = "🗺",
        title_en = "Spatial analytics",      title_zh = "空間分析",
        desc_en  = "GIS workflows, raster analysis, land suitability modelling, PostGIS, R/Python spatial pipelines.",
        desc_zh  = "運用 GIS、遙測與空間模型，從土地、環境到城市活動，發掘隱藏於地理位置背後的關聯與看不見的手。"
      ),
      list(
        icon = "🚌",
        title_en = "Transport data",         title_zh = "大眾運輸資料",
        desc_en  = "GTFS processing, trip planning data, public transport analytics, mobility insights at scale.",
        desc_zh  = "從 GTFS 到大樣本電信信令資料，描繪城市中的流動樣貌，理解人們如何翩翩穿梭於日常生活與都市空間。"
      ),
      list(
        icon = "🏙",
        title_en = "Urban modelling",        title_zh = "城市建模",
        desc_en  = "Urban growth modelling (BrisUrban), 3D city visualisation, land use and activity datasets.",
        desc_zh  = "都市成長預測（BrisUrban)、土地使用分析與3D城市視覺化，探索城市未來可能的樣貌。"
      ),
      list(
        icon = "⚙️",
        title_en = "Data engineering",       title_zh = "資料工程",
        desc_en  = "Cloud pipelines, Apache Spark/Sedona, R/Python packages, large-scale geospatial data processing.",
        desc_zh  = "打造穩定且可重現的資料流程，讓龐大的空間資料得以被有效整合、分析與應用。。"
      )
    )
  ),

  # ── Career chapters ───────────────────────────────────────────────────────
  career = list(
    label_en = "Career chapters",
    label_zh = "職涯篇章",

    chapters = list(
      list(
        style        = "featured",
        badge_en     = "Current · 2025–present",    badge_zh = "現職 · 2025–至今",
        title_en     = "Team Lead, Research and Modelling Unit",
        title_zh     = "研究與建模部門主管",
        org_en       = "Brisbane City Council · City Plan and Design",
        org_zh       = "布里斯本市政府 · 都市規劃與設計處",
        badge_class  = "current",
        tags_en      = c("BrisUrban", "Virtual Brisbane", "Land Use Activity Datasets",
          "Development Activity Datasets", "Team of 10"),
        tags_zh      = c("BrisUrban", "Virtual Brisbane", "土地使用活動資料集",
          "開發活動資料集", "10人團隊")
      ),
      list(
        style        = "pivot-card",
        badge_en     = "Pivot chapter · 2019–2024",  badge_zh = "轉型關鍵 · 2019–2024",
        title_en     = "Principal Data Science Consultant",
        title_zh     = "首席資料科學顧問",
        org_en       = "DSpark (Optus) · Macquarie Park, Sydney",
        org_zh       = "DSpark（Optus）· 雪梨 Macquarie Park",
        badge_class  = "pivot",
        tags_en      = c("Telco Mobility Data (MNO Data)", "GTFS", "Apache Sedona",
          "Client management", "State agencies"),
        tags_zh      = c("電信移動數據（MNO）", "GTFS", "Apache Sedona",
          "客戶管理", "州政府")
      )
    ),

    # Stack evolution
    stack_label_en = "Stack evolution — the open-source pivot",
    stack_label_zh = "技術演進：從單機 GIS 到開源資料科學",
    before_label_en = "Before (2013–2018)",
    before_label_zh = "轉型前 (2013–2018)",
    after_label_en  = "After (2019–present)",
    after_label_zh  = "轉型後 (2019–至今)",

    stack_before = c(
      "ESRI ArcGIS / MapInfo / QGIS DB Manager",
      "Windows",
      "Proprietary data formats",
      "Desktop GIS workflows",
      "Point-and-click analysis"
    ),
    stack_before_zh = c(
      "ESRI ArcGIS / MapInfo / QGIS DB Manager",
      "Windows 系統",
      "封閉資料格式",
      "桌面 GIS 工作流程",
      "點擊式操作分析"
    ),
    stack_after = c(
      "R · Python · SQL",
      "macOS · Cloud (AWS / Azure)",
      "PostGIS · QGIS · OpenStreetMap",
      "Apache Spark · Scala · Sedona",
      "Reproducible pipelines · Open data"
    ),
    stack_after_zh = c(
      "R · Python · SQL",
      "macOS · 雲端（AWS / Azure）",
      "PostGIS · QGIS · OpenStreetMap",
      "Apache Spark · Scala · Sedona",
      "可重現資料流程 · 開源資料"
    ),

    # Career map
    career_map_label_en = "Career locations",
    career_map_label_zh = "工作地點",
    career_map_src      = "career_map.html"
  ),

  # ── Portfolio ─────────────────────────────────────────────────────────────
  portfolio = list(
    label_en = "Selected work",
    label_zh = "精選集",

    cards = list(
      list(
        icon     = "🗺",
        title_en = "My footprint 2013–2025",         title_zh = "我的足跡 2013–2025",
        desc     = "Google Timeline · R + Mapdeck",
        url      = "https://wilsonyungsh.github.io/interactive/30DayMapChallenge2025/Map4_Mydata_2013-2025.html"
      ),
      list(
        icon     = "🏙",
        title_en = "Greater Taipei building heights", title_zh = "大台北建築高度圖",
        desc     = "Overture Maps · R + Mapdeck",
        url      = "https://wilsonyungsh.github.io/interactive/Map29.html"
      ),
      list(
        icon     = "🚌",
        title_en = "SEQ bus service density",         title_zh = "昆士蘭東南區公車服務密度",
        desc     = "3D · R + deck.gl",
        url      = "https://wilsonyungsh.github.io/interactive/map18_seq_bus_service_density.html"
      ),
      list(
        icon     = "🔷",
        title_en = "Brisbane dwelling hexagon map",   title_zh = "布里斯本住宅六角格地圖",
        desc     = "R + MapGL",
        url      = "https://wilsonyungsh.github.io/interactive/Map4_Brisbane_Dwelling.html"
      ),
      list(
        icon     = "🏘",
        title_en = "Greater Brisbane land use change", title_zh = "大布里斯本土地使用變遷",
        desc_en  = "Time &amp; Space · R + MapGL",    desc_zh  = "時間與空間 · R + MapGL",
        url      = "https://wilsonyungsh.github.io/interactive/map12_brisbane_lu_map.html"
      ),
      list(
        icon     = "📊",
        title_en = "PT Service Explorer",             title_zh = "公共運輸服務探索器",
        desc_en  = "R Shiny dashboard · Brisbane GTFS on Hugging Face",
        desc_zh  = "R Shiny 儀表板 · 布里斯本 GTFS · Hugging Face",
        url      = "https://huggingface.co/spaces/wilsonyung/bne_pt_service_explorer"
      ),
      list(
        icon     = "📈",
        title_en = "Bus route accumulative patronage", title_zh = "公車路線累積乘客分析",
        desc_en  = "Stop-level boarding analysis · R + MapGL",
        desc_zh  = "站點累積上車乘人數分析 · R + MapGL",
        url      = "https://wilsonyungsh.github.io/interactive/bus431_capacity.html"
      )
    ),

    see_all_en  = "View all maps →",
    see_all_zh  = "瀏覽所有地圖作品 →",
    see_all_label_en = "Full portfolio",
    see_all_label_zh = "完整作品集錦",
    see_all_url = "https://wilsonyungsh.github.io/map_list.html"
  ),

  # ── Full portfolio page (map_list.html) ──────────────────────────────────
  # 新增作品：在對應 section 的 items 裡加一筆 list(...) 即可。
  # badge  = 選填，例如 "Day 4"（挑戰系列用）
  # tool   = 選填，用的工具/技術
  # desc   = 選填，簡短說明（Shiny/工具類用）
  # links  = 必填，一個或多個 list(label=, url=)
  map_list = list(
    meta_title       = "Portfolio — Wilson Yung",
    meta_description = "Full portfolio of interactive maps, dashboards, and tools by Wilson Yung, spatial data scientist.",
    hero_eyebrow = "Full portfolio",
    hero_title   = "Interactive maps, dashboards &amp; tools.",
    hero_desc    = paste(
      "A complete list of interactive maps, Shiny dashboards, and small tools built with R and the",
      "open-source spatial stack — including entries from the 2024 and 2025 30 Day Map Challenges."
    ),

    sections = list(

      list(
        label = "2024 Map Challenge",
        items = list(
          list(badge="Day 4",  tool="R + MapGL",       title="Hexagon — Brisbane Dwelling Hexagon Map",
               links=list(list(label="View map", url="https://wilsonyungsh.github.io/interactive/Map4_Brisbane_Dwelling.html"))),
          list(badge="Day 5",  tool="R + Mapdeck",     title="Journey — Brisbane My First Cycle Journey",
               links=list(list(label="View map", url="https://wilsonyungsh.github.io/interactive/Map5_Brisbane_cycle_journey.html"))),
          list(badge="Day 11", tool="R + Mapgl",       title="Arctic — Arctic Summit Boundary Ice Map",
               links=list(list(label="View map", url="https://wilsonyungsh.github.io/interactive/Map11_artic_ice_boundary.html"))),
          list(badge="Day 12", tool="R + MapGL",       title="Time &amp; Space — Greater Brisbane Land Use Change Map",
               links=list(list(label="View map", url="https://wilsonyungsh.github.io/interactive/map12_brisbane_lu_map.html"))),
          list(badge="Day 15", tool="R + Mapdeck",     title="My Data — My Fieldtrip Traces",
               links=list(list(label="View map", url="https://wilsonyungsh.github.io/interactive/Map15_fieldtrips.html"))),
          list(badge="Day 18", tool="R + Deck.gl",     title="3D — South East Queensland Bus Service Density",
               links=list(list(label="View map", url="https://wilsonyungsh.github.io/interactive/map18_seq_bus_service_density.html"))),
          list(badge="Day 24", tool="R + Mapgl",       title="Only Circular Shape — Brisbane Toilet Map",
               links=list(list(label="View map", url="https://wilsonyungsh.github.io/interactive/Map24_brisbane_toilets.html"))),
          list(badge="Day 29", tool="R + Mapdeck",     title="Overture Maps — Greater Taipei Building Height",
               links=list(list(label="View map", url="https://wilsonyungsh.github.io/interactive/Map29.html")))
        )
      ),

      list(
        label = "2025 Map Challenge",
        note = 'For the full 30 Day Map Challenge repo, see <a href="https://github.com/wilsonyungsh/30DayMapChallenge2025" target="_blank" rel="noopener">github.com/wilsonyungsh/30DayMapChallenge2025</a>.',
        items = list(
          list(badge="Day 1", tool="R + duckdb + MapGL", title="Overture Map — Ipswich Suburb Address Count Map",
               links=list(list(label="View map", url="https://wilsonyungsh.github.io/interactive/30DayMapChallenge2025/map1_ipswich_address_map.html"))),
          list(badge="Day 3", tool="R + duckdb + MapGL", title="Overture Map — South East Queensland Address Density Map",
               links=list(list(label="View map", url="https://wilsonyungsh.github.io/interactive/30DayMapChallenge2025/map3_address_density_map.html"))),
          list(badge="Day 4", tool="R + Mapdeck",        title="My Data — My Footprint 2013–2025 (Google Timeline)",
               links=list(list(label="View map", url="https://wilsonyungsh.github.io/interactive/30DayMapChallenge2025/Map4_Mydata_2013-2025.html")))
        )
      ),

      list(
        label = "Other projects",
        items = list(
          list(tool="R + Mapdeck", title="Bus Route Cumulative Passenger Count — Brisbane Bus Route 431",
               links=list(list(label="View map", url="https://wilsonyungsh.github.io/interactive/bus431_capacity.html"))),
          list(tool="R + MapGL",   title="2025 June PT Usage by Time Bucket and Trip Direction",
               links=list(list(label="View map", url="https://wilsonyungsh.github.io/interactive/Commuting_trips.html"))),
          list(tool="R + Mapgl",   title="Dwelling Proportion by Motor Vehicle Ownership",
               links=list(
                 list(label="1 or no cars", url="interactive/Dwelling_prop_by_mv_ownership/1orNoMV_dwellings.html"),
                 list(label="2 cars",       url="interactive/Dwelling_prop_by_mv_ownership/2_vehicles_dwelling_prop_over_30pr.html"),
                 list(label="3+ cars",      url="interactive/Dwelling_prop_by_mv_ownership/3_or_more_vehicles_dwelling_prop_over_15pr.html")
               )),
          list(tool="R + MapGL", title="Maps with Felicity",
               links=list(list(label="View map", url="interactive/explore.html"))),
          list(tool="R + MapGL", title="Fly-through Example",
               links=list(list(label="View map", url="interactive/apcs.html"))),
          list(tool="R + MapGL", title="Dual Frontage Map",
               links=list(list(label="View map", url="interactive/dual_frontage.html"))),
          list(tool="R + gganimate", title="Time Lapse Rent Animation — House &amp; Flat, Brisbane",
               links=list(list(label="View animation", url="interactive/plots/House_Flat_brisbane_rent_animation.gif")))
        )
      ),

      list(
        label = "Shiny dashboards",
        items = list(
          list(title="PT Service Explorer",
               desc="Explore stop service-level trends (max headway, service counts), route geometry, switchable layers, and a frequency slider with auto-zoom to route or stops.",
               links=list(
                 list(label="Dashboard",    url="https://wilsonyung.shinyapps.io/BNE_PT_Service_explorer/"),
                 list(label="HF dashboard", url="https://huggingface.co/spaces/wilsonyung/bne_pt_service_explorer")
               ))
        )
      ),

      list(
        label = "Pilot tools",
        items = list(
          list(title="BCC RMU Hotdesk Booking Query", desc="Easier view, with last update, for our team.",
               links=list(list(label="Open tool", url="https://wilsonyungsh.github.io/interactive/team_calendar.html"))),
          list(title="BCC Lvl 8 Hotdesk Booking Query", desc="Easier view, with last update.",
               links=list(list(label="Open tool", url="https://wilsonyungsh.github.io/interactive/team_calendar_lv8.html")))
        )
      )
    )
  ),

  # ── Footer / contact ──────────────────────────────────────────────────────
  footer = list(
    tagline_en   = "Open to spatial, transport, and data consulting engagements.",
    tagline_zh   = "歡迎交流空間分析、運輸資料、都市成長預測與資料工程相關合作。讓資料不只是數字，也成為理解城市的一扇窗。",
    portfolio_en = "Portfolio",
    portfolio_zh = "作品集",
    email        = "wilson0313@gmail.com",
    linkedin     = "https://www.linkedin.com/in/wilson-yung",
    portfolio_url = "https://wilsonyungsh.github.io/map_list.html"
  )
)
