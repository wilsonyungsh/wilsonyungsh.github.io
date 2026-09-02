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

編輯 `script/content.R`，找到 `content$map_list$sections`，在對應分類的 `items` 裡加一筆：

```r
list(tool="R + MapGL", title="新地圖標題",
     links=list(list(label="View map", url="https://wilsonyungsh.github.io/interactive/xxx.html")))
```

- `badge`：選填，例如 `"Day 4"`（挑戰系列用）
- `tool`：選填，用的技術
- `desc`：選填，簡短說明（Shiny/工具類常用）
- `links`：必填，可以放多個（例如一組資料分好幾張圖）
- 全新分類：在 `sections` 直接加一整個 `list(label="分類名稱", items=list(...))`

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

改 `script/career_map.R` 裡的 `locations` 資料，然後在 R 裡重新 source/render 這個腳本（它會呼叫 `htmlwidgets::saveWidget` 之類的輸出到 `career_map.html`）。這個跟 `build.R` 的流程是分開的。

### 6. 加一張新的互動地圖本體

新地圖的 R script 輸出到 `interactive/`（可另外開子資料夾歸類，參考 `30DayMapChallenge2025/`），確定网址能打開後，再照第 1、2 點把它加進作品清單。

## 訪客計數器

頁尾的 Visitors 徽章是外部服務（visitorbadge.io）的圖片，靠 `path` 參數（網址）計數，不需要維護、不需要註冊。`build.R` 裡的 `visitor_badge()` 函式會自動加到兩個頁面的頁尾，改版面時不用擔心會漏掉。
