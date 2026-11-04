# articles.R
# ─────────────────────────────────────────────────────────────────────────────
# 文章內容（中英文），build.R 會把每一篇輸出成 articles/<slug>.html。
# 每篇文章的 blocks 依序排列，type 可以是：
#   h2    = 章節標題（有 id 的話會自動放進文章開頭的目錄）
#   date  = 小字日期
#   h3    = 小標題
#   p     = 段落（可含 <a href='...'>，記得用單引號）
#   ul    = 清單，items 裡每筆 list(en=, zh=)；plain=TRUE 不顯示圓點（項目本身用 emoji 開頭時）
#   img   = 圖片，src 從 repo 根目錄算起，另填 alt_en/alt_zh、cap_en/cap_zh（選填）
#   links = 地圖 / 程式碼 / LinkedIn 連結列，map / code / post 三個網址都選填
# 文字裡不要用雙引號 "，要用的話改用 “ ” 。
# ─────────────────────────────────────────────────────────────────────────────

repo_2026 <- "https://github.com/wilsonyungsh/30DayMapChallenge2026"
maps_2026 <- "https://wilsonyungsh.github.io/interactive/30DayMapChallenge2026/"
img_2026  <- "img/articles/30daymapchallenge-2026/"

articles <- list(

  list(
    slug     = "30daymapchallenge-2026",
    meta_title       = "#30DayMapChallenge 2026 — Wilson Yung",
    meta_description = "Wilson Yung's #30DayMapChallenge 2026: the maps, the data and the stories behind them.",
    eyebrow_en = "Article · Updated 4 Nov 2026",
    eyebrow_zh = "文章 · 更新於 2026 年 11 月 4 日",
    title_en = "My #30DayMapChallenge 2026",
    title_zh = "我的 2026 #30DayMapChallenge 三十天地圖挑戰",
    lede_en  = paste(
      "Every November, the #30DayMapChallenge asks for a map a day, each on a different theme.",
      "This is my third year taking part. These are my 2026 maps and the stories behind them,",
      "first shared on LinkedIn. I’ll add new days as the month goes on."
    ),
    lede_zh  = paste0(
      "每年十一月的 #30DayMapChallenge，每天一個主題、每天一張地圖。",
      "今年是我第三年參加。這篇整理了我 2026 年的作品和背後的故事，",
      "內容最早分享在 LinkedIn 上，會隨著挑戰進行持續更新。"
    ),

    blocks = list(

      # ── Day 1 ──────────────────────────────────────────────────────────────
      list(type="h2", id="day-1", en="Day 1 · Points 📍", zh="第 1 天 · 點 📍"),
      list(type="date", en="1 Nov 2026", zh="2026 年 11 月 1 日"),
      list(type="p",
           en="2026 is a Census year in Australia, so I started with the smallest unit of census geography: the ABS Mesh Block.",
           zh="2026 年是澳洲的人口普查年，所以第一天我從普查地理最小的單位開始：澳洲統計局（ABS）的網格區塊（Mesh Block）。"),
      list(type="p",
           en="I plotted all 374,803 Mesh Blocks (ASGS 2026) as centroid points, coloured by land use. Counting them and measuring their area tell two very different stories:",
           zh="我把全部 374,803 個網格區塊（ASGS 2026）畫成質心點，依土地使用分類上色。用數量看和用面積看，會說出兩個截然不同的故事："),
      list(type="ul", plain=TRUE, items=list(
        list(en="🏠 Residential Mesh Blocks are 66.4% of the count but cover only 0.4% of the land",
             zh="🏠 住宅區塊佔總數的 66.4%，面積卻只佔 0.4%"),
        list(en="🌾 Primary Production Mesh Blocks are 5.2% of the count but cover 76.8% of Australia",
             zh="🌾 初級產業（農牧）區塊只佔總數的 5.2%，面積卻涵蓋全澳 76.8%")
      )),
      list(type="p",
           en="Mesh Blocks are designed to hold roughly similar numbers of dwellings, so they shrink where people live and stretch out where they don’t. By count, Australia looks residential. By area, it’s farmland and outback.",
           zh="網格區塊的設計是讓每一塊的住宅數量大致相近，所以人多的地方區塊小，人少的地方區塊大。按數量看，澳洲像一大片住宅區；按面積看，澳洲其實是農地和內陸荒原（outback）。"),
      list(type="img", src=paste0(img_2026, "day1-points.jpg"),
           alt_en="Map of Australia with every ABS Mesh Block shown as a point coloured by land use",
           alt_zh="澳洲地圖，每個 ABS 網格區塊以點表示，依土地使用分類上色",
           cap_en="All 374,803 Mesh Blocks as centroids, with the count vs area table.",
           cap_zh="全部 374,803 個網格區塊的質心點，以及數量與面積對照表。"),
      list(type="h3", en="What I learned this time: keep the map lean", zh="這次學到的事：地圖要精簡"),
      list(type="p",
           en="My first export of the interactive map was 250MB, too big to host. GitHub caps files at 100MB. Getting it down to 94MB meant cutting everything the map didn’t need: attributes nobody looks at, extra layers, and anything “nice to have” in the popup. Every column you keep gets copied 374,803 times.",
           zh="互動地圖第一次匯出時有 250MB，大到沒辦法放上網，GitHub 單一檔案的上限是 100MB。為了壓到 94MB，我把地圖用不到的東西全部拿掉：沒人會看的屬性欄位、多餘的圖層，還有彈出視窗裡那些「有了也不錯」的資訊。你保留的每一個欄位，都會被複製 374,803 次。"),
      list(type="p",
           en="The lesson: decide what the map has to say, and leave everything else out. A smaller file loads faster, and the message comes through more clearly.",
           zh="學到的一課：先決定這張地圖要說什麼，其他的都拿掉。檔案越小載入越快，想傳達的訊息也越清楚。"),
      list(type="p",
           en="Built in R with mapgl (MapLibre GL JS). I pulled the Mesh Blocks with abs.geo, a small helper package I wrote for getting ABS geographies. You can also download them straight from the ABS website or use the {strayr} package.",
           zh="使用 R 的 mapgl（MapLibre GL JS）製作。網格區塊是用 abs.geo 取得的，這是我自己寫的小套件，用來下載 ABS 的地理邊界。你也可以直接從 ABS 網站下載，或使用 {strayr} 套件。"),
      list(type="links",
           map  = paste0(maps_2026, "day1_aus26_mb.html"),
           code = paste0(repo_2026, "/blob/main/scripts/Day1_abs_census_mb_pt.r"),
           post = "https://www.linkedin.com/feed/update/urn:li:activity:7522439770526883840/"),

      # ── Day 2 ──────────────────────────────────────────────────────────────
      list(type="h2", id="day-2", en="Day 2 · Lines ⛴️", zh="第 2 天 · 線 ⛴️"),
      list(type="date", en="2 Nov 2026", zh="2026 年 11 月 2 日"),
      list(type="p",
           en="Growing up in Kaohsiung, my only ferry memory is riding my scooter onto the Cijin ferry (旗津渡輪). Sometimes I went across as a passenger instead.",
           zh="在高雄長大的我，唯一的渡輪記憶是騎著機車上旗津渡輪，有時候則是單純當乘客坐過去。"),
      list(type="p",
           en="That’s a little ironic. I’m Taiwanese, from an island surrounded by ocean, and I grew up in a harbour city, yet water transport barely featured in my life.",
           zh="說起來有點諷刺。我是台灣人，來自四面環海的島嶼，又在港都長大，水上交通卻幾乎不在我的生活裡。"),
      list(type="p",
           en="That changed when I worked at TomTom. In the map data I saw ferries of every kind: passenger ferries, vehicle ferries, river crossings, island links. So for Day 2, I mapped water transport routes across Australia.",
           zh="直到我在 TomTom 工作後才改變。在圖資裡，我看到各式各樣的渡輪：客運渡輪、汽車渡輪、渡河航線、跳島航線。所以第二天，我畫了全澳洲的水上運輸航線。"),
      list(type="h3", en="What the map shows", zh="地圖呈現了什麼"),
      list(type="p",
           en="Overture has 162 water transport routes in Australia, totalling about 4,690 km.",
           zh="Overture 收錄了澳洲 162 條水上運輸航線，總長約 4,690 公里。"),
      list(type="ul", plain=TRUE, items=list(
        list(en="🌊 Queensland has the most routes: 61 routes and 666 km in total, mostly short island and reef hops along the coast.",
             zh="🌊 昆士蘭的航線最多：61 條、總長 666 公里，大多是沿岸跳島和往返珊瑚礁的短程航線。"),
        list(en="🚢 The Northern Territory has only 6 routes, but they add up to 2,560 km, more than half the national total. These are long-haul barges serving remote communities. The longest, Darwin–Nhulunbuy–Groote Eylandt, is over 1,100 km by itself.",
             zh="🚢 北領地只有 6 條航線，加起來卻有 2,560 公里，超過全國總長的一半。這些是服務偏遠社區的長程駁船，最長的達爾文–努蘭拜–格魯特島（Darwin–Nhulunbuy–Groote Eylandt）一條就超過 1,100 公里。"),
        list(en="⛴️ Geelong–Devonport, the Spirit of Tasmania route, is the fifth longest at 449 km.",
             zh="⛴️ 吉朗–德文港（Geelong–Devonport），也就是塔斯馬尼亞之靈號（Spirit of Tasmania）的航線，以 449 公里排名第五長。"),
        list(en="🏙️ NSW has 48 routes but only 74 km in total. Lots of short harbour and river crossings.",
             zh="🏙️ 新南威爾斯有 48 條航線，總長卻只有 74 公里，大多是港灣和河流的短程渡輪。")
      )),
      list(type="p",
           en="Like Mesh Block count versus area on Day 1, route count and route length tell different stories.",
           zh="就像第一天網格區塊的數量和面積，航線的數量和長度也說出不同的故事。"),
      list(type="img", src=paste0(img_2026, "day2-lines.jpg"),
           alt_en="Map of Australia's water transport routes from Overture Maps, with a table of routes and length by state",
           alt_zh="Overture Maps 的澳洲水上運輸航線地圖，附各州航線數與長度表",
           cap_en="162 water transport routes from Overture Maps, with route count and length by state.",
           cap_zh="Overture Maps 的 162 條水上運輸航線，附各州航線數與總長。"),
      list(type="h3", en="A note on data gaps", zh="關於資料缺漏"),
      list(type="p",
           en="Open data isn’t complete. I couldn’t find some routes I know well, such as the Circular Quay to Watsons Bay ferry in Sydney, or the Dangar Island ferry on the Hawkesbury. Treat the map as a picture of what’s in Overture, not as a full ferry network. If you spot a missing route, it could be worth contributing it to OpenStreetMap, which feeds Overture.",
           zh="開放資料並不完整。有些我很熟的航線在資料裡找不到，例如雪梨環形碼頭（Circular Quay）到華生灣（Watsons Bay）的渡輪，或霍克斯伯里河（Hawkesbury）上往丹格島（Dangar Island）的渡輪。請把這張地圖當作 Overture 現有資料的樣貌，而不是完整的渡輪路網。如果你發現缺了哪條航線，不妨把它貢獻到 OpenStreetMap，Overture 有一部分資料就是來自那裡。"),
      list(type="h3", en="How I made it", zh="製作方式"),
      list(type="p",
           en="The data comes from the Overture Maps October 2026 release. I extracted the water routes for Australia with DuckDB and mapped them in R. DuckDB reads Overture’s GeoParquet files straight from the cloud, so you only download the part you need, not the whole planet.",
           zh="資料來自 Overture Maps 2026 年 10 月的版本。我用 DuckDB 擷取澳洲的水上航線，再用 R 製圖。DuckDB 可以直接從雲端讀取 Overture 的 GeoParquet 檔案，只要下載需要的那一小塊，不用把整個地球的資料都抓下來。"),
      list(type="h3", en="My own ferry list", zh="我的渡輪清單"),
      list(type="p", en="My own ferry list is still very short:", zh="我自己搭過的渡輪還很少："),
      list(type="ul", plain=TRUE, items=list(
        list(en="🚢 Sydney: the Parramatta RiverCat, the Manly fast ferry, and the Berowra Waters vehicle ferry, which I loved",
             zh="🚢 雪梨：帕拉馬塔河的 RiverCat、曼利快速渡輪，還有我很喜歡的貝羅拉水域（Berowra Waters）汽車渡輪"),
        list(en="🚢 Brisbane: the KittyCat and the RiverCat, plus the North Stradbroke Island ferry 12 years ago",
             zh="🚢 布里斯本：KittyCat 和 RiverCat，以及 12 年前搭過的北斯特拉布羅克島（North Stradbroke Island）渡輪"),
        list(en="🚢 Europe: Helsinki to Tallinn across the Baltic 12 years ago, and around 20 years ago the Danube river ferry from Linz to Passau and the ferry in Hallstatt",
             zh="🚢 歐洲：12 年前橫渡波羅的海，從赫爾辛基到塔林；大約 20 年前搭過從林茲到帕紹的多瑙河渡輪，還有哈修塔特（Hallstatt）的渡輪")
      )),
      list(type="p",
           en="What’s your water transport story? Is there a ferry ride you still remember, or one on your list?",
           zh="你有什麼水上交通的故事嗎？有沒有一趟至今還記得的渡輪，或是一直想搭的航線？"),
      list(type="links",
           map  = paste0(maps_2026, "day2_aus_water_routes.html"),
           code = paste0(repo_2026, "/blob/main/scripts/Day2_route1_highway_line.r"),
           post = "https://www.linkedin.com/feed/update/urn:li:activity:7522902477080383488/"),

      # ── Day 3 ──────────────────────────────────────────────────────────────
      list(type="h2", id="day-3", en="Day 3 · Polygons 🏞️", zh="第 3 天 · 多邊形 🏞️"),
      list(type="date", en="3 Nov 2026", zh="2026 年 11 月 3 日"),
      list(type="p",
           en="My first snorkeling was in 2001, in Kenting National Park (墾丁國家公園) at the southern tip of Taiwan.",
           zh="我第一次浮潛是在 2001 年，地點是台灣最南端的墾丁國家公園。"),
      list(type="img", src=paste0(img_2026, "day3-kenting-2001.jpg"),
           alt_en="A group snorkeling in shallow water at Kenting National Park in 2001",
           alt_zh="2001 年在墾丁國家公園淺水區浮潛的一群人",
           cap_en="My first snorkeling trip, Kenting National Park, 2001. That’s me in the photo.",
           cap_zh="我的第一次浮潛，墾丁國家公園，2001 年。照片裡有我。"),
      list(type="p",
           en="For Day 3, I’m going back home to map Taiwan’s administrative boundaries and national parks.",
           zh="第三天，我回到家鄉，畫台灣的行政區界和國家公園。"),
      list(type="p",
           en="When I was young, Taiwan had only 6 national parks. Thirty years later there are 10: 9 national parks plus Shoushan National Nature Park. I’ve only been to a few of them: Taroko (太魯閣), Kenting (墾丁), Yangmingshan (陽明山) and Shoushan (壽山). I’d love to visit the rest.",
           zh="我小時候，台灣只有 6 座國家公園。三十年後已經有 10 座：9 座國家公園，再加上壽山國家自然公園。我只去過其中幾座：太魯閣、墾丁、陽明山和壽山，希望有一天能把其他的也走完。"),
      list(type="h3", en="What the map shows", zh="地圖呈現了什麼"),
      list(type="p", en="🏙️ Taiwan’s three tiers of local government:", zh="🏙️ 台灣的三種地方行政層級："),
      list(type="ul", items=list(
        list(en="Special municipalities (直轄市), e.g. Taipei and Kaohsiung", zh="直轄市，例如台北、高雄"),
        list(en="Provincial cities (省轄市), e.g. Keelung, Hsinchu and Chiayi", zh="省轄市，例如基隆、新竹、嘉義"),
        list(en="Counties (縣)", zh="縣")
      )),
      list(type="p",
           en="Special municipalities sit at the top. They get more budget and more autonomy, and they hold most of Taiwan’s population.",
           zh="直轄市位階最高，預算較多、自治權也較大，台灣大部分的人口都住在直轄市。"),
      list(type="p",
           en="🌳 National parks drawn over the administrative map, so you can see which cities and counties each park sits in.",
           zh="🌳 國家公園疊在行政區地圖上，可以看出每座國家公園位在哪些縣市。"),
      list(type="img", src=paste0(img_2026, "day3-polygons.jpg"),
           alt_en="3D map of Taiwan's cities and counties with national parks extruded in green",
           alt_zh="台灣縣市的 3D 地圖，國家公園以綠色立體多邊形呈現",
           cap_en="Taiwan’s cities and counties by tier, with national parks extruded and shaded by area.",
           cap_zh="依行政層級上色的台灣縣市，國家公園以立體呈現，顏色深淺代表面積。"),
      list(type="h3", en="Data &amp; tools", zh="資料與工具"),
      list(type="p",
           en="Boundaries come from OpenStreetMap and GADM. The OpenStreetMap boundary also covers the waters around Taiwan, not just the land, so it gives you a different view of what “Taiwan” looks like on a map.",
           zh="行政界線來自 OpenStreetMap 和 GADM。OpenStreetMap 的台灣邊界不只涵蓋陸地，也包含周邊海域，讓你從另一個角度看「台灣」在地圖上的樣子。"),
      list(type="p",
           en="Built in R with mapgl (MapLibre GL JS). Most legends can be collapsed and dragged around, so they don’t block the map.",
           zh="使用 R 的 mapgl（MapLibre GL JS）製作。大部分圖例都可以收合和拖曳，不會擋住地圖。"),
      list(type="links",
           map  = paste0(maps_2026, "day3_tw_boundary_national_parks.html"),
           code = paste0(repo_2026, "/blob/main/scripts/Day3_tw_national_parks_polygon.R"),
           post = "https://www.linkedin.com/feed/update/urn:li:activity:7523261351444705280/")
    ),

    outro_en = paste0(
      "More days to come. Every 2026 map is listed in my <a href='../map_list.html'>full portfolio</a>, ",
      "and the code is on <a href='", repo_2026, "' target='_blank' rel='noopener'>GitHub</a>."
    ),
    outro_zh = paste0(
      "後續幾天的作品會陸續加上來。2026 年的所有地圖都列在<a href='../map_list.html'>完整作品集</a>，",
      "程式碼放在 <a href='", repo_2026, "' target='_blank' rel='noopener'>GitHub</a>。"
    )
  )
)
