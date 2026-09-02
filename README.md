# wilsonyungsh.github.io

Personal website，純靜態 GitHub Pages（沒有後端）。

這份 README 是給自己看的維護筆記：之後要改內容、加作品時，照這裡的步驟做，不要直接手改 `index.html` / `map_list.html`，因為這兩個檔案是**產生出來的**，重跑 build 腳本就會被蓋掉。

## 網站結構

| 檔案 / 資料夾 | 說明 |
|---|---|
| `index.html` | 首頁。由 `script/build.R` 從 `script/content.R` 產生，**不要手改**。 |
| `map_list.html` | 完整作品集頁面。同樣由 `script/build.R` 產生，**不要手改**。 |
| `script/content.R` | 所有文字內容（中英文）、作品清單資料，集中在這裡。**要改內容改這裡**。 |
| `script/build.R` | 讀 `content.R`，組出 `index.html` 和 `map_list.html` 的 HTML。改版面/樣式才需要動這個檔案。 |
| `script/career_map.R` | 產生 `career_map.html`（工作地點地圖），用 `mapgl` 畫的獨立 widget，`index.html` 用 `<iframe>` 嵌入。這個是獨立產生的檔案，跟 `build.R` 無關。 |
| `career_map.html` | `career_map.R` 的輸出，同樣是產生檔，不要手改，改完 `career_map.R` 要重新 render。 |
| `interactive/` | 每張互動地圖／小工具各自的獨立 HTML（R + mapgl / mapdeck / deck.gl 輸出），是各作品實際的內容頁，被首頁和 `map_list.html` 用連結指過去。 |
| `.nojekyll` | 停用 GitHub Pages 預設的 Jekyll 處理。沒有這個檔案，GitHub 會想把 `.md` 檔轉成網頁，可能跟手動產生的 `.html` 撞名。**不要刪掉**。 |

## 常見任務

### 1. 新增一筆作品到「完整作品集」(map_list.html)

`map_list.html` 現在也有 EN/ZH 切換（跟首頁一樣），所以標題、說明、連結文字都要中英文一起填。編輯 `script/content.R`，找到 `content$map_list$sections`，在對應分類的 `items` 裡加一筆：

```r
list(tool="R + MapGL", title_en="New map title", title_zh="新地圖標題",
     links=list(list(label_en="View map", label_zh="查看地圖", url="https://wilsonyungsh.github.io/interactive/xxx.html")))
```

- `badge`：選填，例如 `"Day 4"`（挑戰系列用，中英通用不用分語言）
- `tool`：選填，用的技術（中英通用）
- `title_en` / `title_zh`：必填
- `desc_en` / `desc_zh`：選填，簡短說明（Shiny/工具類常用）
- `links`：必填，可以放多個（例如一組資料分好幾張圖），每個要有 `label_en` / `label_zh`
- 全新分類：在 `sections` 直接加一整個 `list(label_en="...", label_zh="...", items=list(...))`
- 如果分類要加說明文字（像「2025 Map Challenge」下面那行連結原始碼的 `note_en`/`note_zh`），裡面若有 `<a href="...">` 這種 HTML，記得用單引號寫屬性（`href='...'`），不要用雙引號，不然會跟外層的 `data-en="..."` 屬性衝突把字串截斷。

### 2. 把作品加進首頁「精選集」(index.html #portfolio)

編輯 `script/content.R`，在 `content$portfolio$cards` 加一筆：

```r
list(
  icon     = "🗺",
  title_en = "英文標題", title_zh = "中文標題",
  desc     = "工具 / 說明",
  url      = "https://wilsonyungsh.github.io/interactive/xxx.html"
)
```

首頁精選集是策展過的一小部分（現在 7 筆），不用每個作品都放進去，重要/代表性的才放。

### 3. 改文字內容（Hero、專長、職涯篇章、Footer 等）

全部在 `script/content.R`，中英文成對出現（`_en` / `_zh` 結尾），找到對應區塊改就好，結構本身不用動。

### 4. 套用變更

改完 `content.R` 後，在 repo 根目錄跑：

```bash
Rscript script/build.R
```

會同時重新產生 `index.html` 和 `map_list.html`。跑完檢查一下 `git diff` 再 commit / push。

### 5. 更新工作地點地圖 (career_map.html)

改 `script/career_map.R` 裡的 `locations` 資料，然後跑：

```bash
Rscript script/career_map.R
```

會直接輸出 `career_map.html`。這個跟 `build.R` 的流程是分開的（不用改完 career_map.R 又跑 build.R，也不用反過來）。

需要系統裝了 **pandoc**（`htmlwidgets::saveWidget(selfcontained = TRUE)` 需要它來打包成單一 HTML 檔），沒裝的話 `brew install pandoc`。

- **分類（legend）**：地圖上的分類是「產業別」，不是年資/職涯階段。改 `locations$industry`（每個地點一個分類）和 `industry_colours`（分類 → 顏色，同時也是圖例的內容和順序）。想加新分類就在 `industry_colours` 加一行，並讓對應地點的 `industry` 用一樣的名稱。**盡量維持在 5–7 類以內**，太多的話圖例會很擠。
- **Marker 就是各公司 logo**：地圖上每個點用的是該機構的 logo（`logo_url`／`logo_key` 兩欄，優先用 Google favicon service，知名品牌用 [Simple Icons](https://simpleicons.org) 的白色版本），不是預設的地圖大頭針。加新地點時記得也要補這兩欄，不然那個點會沒有 logo（只剩底下的顏色圓點）。

### 6. 加一張新的互動地圖本體

新地圖的 R script 輸出到 `interactive/`（可另外開子資料夾歸類，參考 `30DayMapChallenge2025/`），確定网址能打開後，再照第 1、2 點把它加進作品清單。

## 訪客計數器

頁尾的 Visitors 徽章是外部服務（visitorbadge.io）的圖片，靠 `path` 參數（網址）計數，不需要維護、不需要註冊。`build.R` 裡的 `visitor_badge()` 函式會自動加到兩個頁面的頁尾，改版面時不用擔心會漏掉。

## 中文字型

英文用 DM Sans / DM Mono（Google Fonts），這兩個字型沒有中文字符。中文（以及任何西文字型顯示不出來的字）會自動 fallback 到 **LXGW WenKai TC（霞鶩文楷）**，在 `build.R` 的 `--sans` / `--mono` CSS 變數裡設定：

```css
--mono:"DM Mono","LXGW WenKai TC",monospace;
--sans:"DM Sans","LXGW WenKai TC",system-ui,sans-serif;
```

這個字型只有 300 / 400 / 700 三個字重（`<link>` 標籤裡 `LXGW+WenKai+TC:wght@300;400;700`），如果之後想換掉，記得兩個地方都要改：`<link href="https://fonts.googleapis.com/css2?...">` 的 `family=` 參數，以及上面這兩行 CSS 變數（`css` 和 `css_map` 兩個變數都要改，分別對應首頁和作品集頁）。
