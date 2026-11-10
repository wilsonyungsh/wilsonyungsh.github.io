# build.R
# 執行這個檔案產生 index.html。修改文字請只動 content.R。

source("script/content.R")

# ── 小工具函數 ────────────────────────────────────────────────────────────────

i18n <- function(en, zh) {
  paste0('data-i18n data-en="', en, '" data-zh="', zh, '"')
}

domain_card <- function(d) {
  paste0(
    '\n        <div class="domain-card">',
    '\n          <span class="domain-icon">', d$icon, "</span>",
    "\n          <h3 ", i18n(d$title_en, d$title_zh), ">", d$title_en, "</h3>",
    "\n          <p ",  i18n(d$desc_en,  d$desc_zh),  ">",  d$desc_en,  "</p>",
    "\n        </div>"
  )
}

tag_row <- function(tags_en, tags_zh) {
  paste(mapply(function(en, zh) {
    paste0('<span class="tag" ', i18n(en, zh), ">", en, "</span>")
  }, tags_en, tags_zh), collapse = "\n            ")
}

chapter_card <- function(ch) {
  paste0(
    '\n        <div class="chapter-card ', ch$style, '">',
    '\n          <span class="chapter-badge ', ch$badge_class, '" ', i18n(ch$badge_en, ch$badge_zh), ">", ch$badge_en, "</span>",
    "\n          <h3 ", i18n(ch$title_en, ch$title_zh), ">", ch$title_en, "</h3>",
    '\n          <p class="org" ', i18n(ch$org_en, ch$org_zh), ">", ch$org_en, "</p>",
    '\n          <div class="tag-row">\n            ', tag_row(ch$tags_en, ch$tags_zh),
    "\n          </div>",
    "\n        </div>"
  )
}

stack_items <- function(items_en, items_zh, cls) {
  paste(mapply(function(en, zh) {
    paste0('<div class="stack-item ', cls, '" ', i18n(en, zh), ">", en, "</div>")
  }, items_en, items_zh), collapse = "\n            ")
}

visitor_badge <- function(path) {
  paste0(
    '\n    <div class="inner" style="padding-top:0;">',
    '\n      <img class="visitor-badge" alt="Visitor count" loading="lazy"',
    '\n        src="https://api.visitorbadge.io/api/visitors?path=https%3A%2F%2Fwilsonyungsh.github.io%2F', path,
    '&label=Visitors&labelColor=%23f7f6f2&countColor=%232B5F8E&style=flat-square">',
    "\n    </div>"
  )
}

port_card <- function(p) {
  has_bilingual <- !is.null(p$desc_en)
  desc_attr <- if (has_bilingual) paste0(" ", i18n(p$desc_en, p$desc_zh)) else ""
  desc_text <- if (has_bilingual) p$desc_en else p$desc
  paste0(
    '\n        <a class="port-card" href="', p$url, '" target="_blank" rel="noopener">',
    '\n          <div class="port-thumb">', p$icon, "</div>",
    '\n          <div class="port-info">',
    "\n            <h3 ", i18n(p$title_en, p$title_zh), ">", p$title_en, "</h3>",
    "\n            <p", desc_attr, ">", desc_text, "</p>",
    "\n          </div>",
    "\n        </a>"
  )
}

map_links_html <- function(links) {
  paste(lapply(links, function(l) {
    paste0('<a href="', l$url, '" target="_blank" rel="noopener"><span ', i18n(l$label_en, l$label_zh), ">", l$label_en, '</span> <span class="arrow">→</span></a>')
  }), collapse = "\n            ")
}

map_card <- function(item) {
  top <- NULL
  if (!is.null(item$badge) || !is.null(item$tool)) {
    top <- paste0(
      '\n          <div class="map-card-top">',
      if (!is.null(item$badge)) paste0('<span class="map-badge">', item$badge, "</span>") else "",
      if (!is.null(item$tool))  paste0('<span class="map-tool">', item$tool, "</span>")   else "",
      "</div>"
    )
  }
  desc <- if (!is.null(item$desc_en)) paste0('\n          <p ', i18n(item$desc_en, item$desc_zh), ' style="font-size:13px;color:var(--text-2);line-height:1.6;">', item$desc_en, "</p>") else ""
  paste0(
    '\n        <div class="map-card">',
    if (!is.null(top)) top else "",
    '\n          <p class="map-title" ', i18n(item$title_en, item$title_zh), ">", item$title_en, "</p>",
    desc,
    '\n          <div class="map-links">\n            ', map_links_html(item$links),
    "\n          </div>",
    "\n        </div>"
  )
}

map_section <- function(sec) {
  cards_html <- paste(lapply(sec$items, map_card), collapse = "")
  note_html <- if (!is.null(sec$note_en)) paste0('\n      <p class="note" ', i18n(sec$note_en, sec$note_zh), ">", sec$note_en, "</p>") else ""
  count_html <- if (length(sec$items) > 1) {
    paste0('\n        <p class="section-count" ', i18n(paste0(length(sec$items), " maps"), paste0(length(sec$items), " 個作品")), ">", length(sec$items), " maps</p>")
  } else ""
  paste0(
    '\n  <div class="container">',
    '\n    <section>',
    '\n      <div class="section-head">',
    '\n        <p class="section-label" ', i18n(sec$label_en, sec$label_zh), ">", sec$label_en, "</p>",
    count_html,
    "\n      </div>",
    '\n      <div class="map-grid">',
    cards_html,
    "\n      </div>",
    note_html,
    "\n    </section>",
    "\n  </div>"
  )
}

# ── 組裝內容 ──────────────────────────────────────────────────────────────────

c_   <- content
nav  <- c_$nav
hero <- c_$hero
fp   <- c_$footprint
exp  <- c_$expertise
car  <- c_$career
port <- c_$portfolio
ftr  <- c_$footer

domain_cards_html  <- paste(lapply(exp$domains,  domain_card),  collapse = "")
chapter_cards_html <- paste(lapply(car$chapters, chapter_card), collapse = "")
port_cards_html    <- paste(lapply(port$cards,   port_card),    collapse = "")

chips_accent_html <- paste(
  paste0('<span class="chip accent">', hero$chips_accent, "</span>"),
  collapse = "\n        "
)
chips_domain_html <- paste(mapply(function(en, zh) {
  paste0('<span class="chip" ', i18n(en, zh), ">", en, "</span>")
}, hero$chips_en, hero$chips_zh), collapse = "\n        ")

# ── CSS (별도 변수로 분리하여 sprintf %% 문제 회피) ───────────────────────────
css <- '    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
    :root {
      --bg:#f7f6f2;--surface:#ffffff;--border:rgba(0,0,0,0.08);--border-md:rgba(0,0,0,0.13);
      --text-1:#1a1917;--text-2:#4a4845;--text-3:#8a8784;
      --accent:#2B5F8E;--accent-lt:#e8f0f8;--accent-border:#b8cfe4;
      --pivot:#C4783A;--pivot-lt:#fdf0e6;--pivot-border:#e8c9a8;
      --nav-bg:rgba(247,246,242,0.88);--map-placeholder-bg:#eef2f6;
      --stack-old-bg:#f5f4f0;--stack-new-bg:#edf4ee;--stack-new-text:#2d6b35;--stack-new-border:#c8dfc9;
      --mono:"DM Mono","LXGW WenKai TC",monospace;--sans:"DM Sans","LXGW WenKai TC",system-ui,sans-serif;
      --radius-sm:6px;--radius-md:10px;--radius-lg:16px;
    }
    /* Dark theme — follows system preference by default; data-theme attribute
       (set by the toggle button, persisted in localStorage) overrides it. */
    @media(prefers-color-scheme:dark){
      :root:not([data-theme="light"]) {
        --bg:#15151a;--surface:#1e1e25;--border:rgba(255,255,255,0.08);--border-md:rgba(255,255,255,0.14);
        --text-1:#f0efec;--text-2:#b7b4ad;--text-3:#7d7a73;
        --accent:#6FA8D8;--accent-lt:rgba(111,168,216,0.14);--accent-border:rgba(111,168,216,0.35);
        --pivot:#E0985C;--pivot-lt:rgba(224,152,92,0.14);--pivot-border:rgba(224,152,92,0.35);
        --nav-bg:rgba(21,21,26,0.85);--map-placeholder-bg:#1c1c22;
        --stack-old-bg:#232228;--stack-new-bg:rgba(76,175,120,0.14);--stack-new-text:#6fcf97;--stack-new-border:rgba(111,207,151,0.35);
      }
    }
    :root[data-theme="dark"] {
      --bg:#15151a;--surface:#1e1e25;--border:rgba(255,255,255,0.08);--border-md:rgba(255,255,255,0.14);
      --text-1:#f0efec;--text-2:#b7b4ad;--text-3:#7d7a73;
      --accent:#6FA8D8;--accent-lt:rgba(111,168,216,0.14);--accent-border:rgba(111,168,216,0.35);
      --pivot:#E0985C;--pivot-lt:rgba(224,152,92,0.14);--pivot-border:rgba(224,152,92,0.35);
      --nav-bg:rgba(21,21,26,0.85);--map-placeholder-bg:#1c1c22;
      --stack-old-bg:#232228;--stack-new-bg:rgba(76,175,120,0.14);--stack-new-text:#6fcf97;--stack-new-border:rgba(111,207,151,0.35);
    }
    html { scroll-behavior: smooth; }
    body { font-family:var(--sans);background:var(--bg);color:var(--text-1);font-size:17px;line-height:1.7;-webkit-font-smoothing:antialiased;transition:background-color 0.25s ease,color 0.25s ease; }
    .container { max-width:900px;margin:0 auto;padding:0 24px; }
    nav { position:sticky;top:0;z-index:100;background:var(--nav-bg);backdrop-filter:blur(12px);border-bottom:1px solid var(--border);padding:14px 0;transition:background-color 0.25s ease,border-color 0.25s ease; }
    nav .inner { max-width:900px;margin:0 auto;padding:0 24px;display:flex;align-items:center;gap:28px; }
    .nav-logo { font-size:15px;font-weight:500;color:var(--text-1);text-decoration:none;margin-right:auto;letter-spacing:-0.01em; }
    .nav-logo span { color:var(--text-3);font-weight:300; }
    nav a { font-size:14px;color:var(--text-3);text-decoration:none;transition:color 0.15s; }
    nav a:hover { color:var(--text-1); }
    .lang-toggle { font-family:var(--mono);font-size:11px;font-weight:500;padding:5px 12px;border-radius:100px;border:1.5px solid var(--accent);background:var(--accent-lt);color:var(--accent);cursor:pointer;transition:all 0.2s;white-space:nowrap;flex-shrink:0;letter-spacing:0.03em; }
    .lang-toggle:hover { background:var(--accent);color:#ffffff;border-color:var(--accent); }
    .theme-toggle { font-size:14px;width:32px;height:32px;border-radius:50%;border:1.5px solid var(--accent);background:var(--accent-lt);color:var(--accent);cursor:pointer;transition:all 0.2s;display:flex;align-items:center;justify-content:center;flex-shrink:0;padding:0;line-height:1; }
    .theme-toggle:hover { background:var(--accent);color:#ffffff;border-color:var(--accent); }
    .hero { padding:0 0 56px; }
    .hero-eyebrow { font-family:var(--mono);font-size:12px;color:var(--text-3);letter-spacing:0.04em;margin-bottom:16px; }
    .hero h1 { font-size:clamp(32px,5vw,48px);font-weight:300;letter-spacing:-0.03em;line-height:1.15;color:var(--text-1);margin-bottom:20px; }
    .hero h1 em { font-style:italic;color:var(--text-3); }
    .hero-desc { font-size:18px;color:var(--text-2);max-width:560px;margin-bottom:28px;line-height:1.75; }
    .chip-row { display:flex;flex-wrap:wrap;gap:8px; }
    .chip { font-family:var(--mono);font-size:11px;padding:5px 11px;border-radius:100px;border:1px solid var(--border-md);color:var(--text-2);background:var(--surface);white-space:nowrap; }
    .chip.accent { background:var(--accent-lt);border-color:var(--accent-border);color:var(--accent); }
    /* Full-bleed hero banner — image only, breaks out of the .container
       max-width on purpose (Option A from the banner design review). No
       text sits on the photo any more (v2: it collided with the profile
       avatar) — title/chips/desc all live below, in normal flow, so the
       avatar (straddling the banner/page boundary) never overlaps them. */
    .hero-banner { position:relative;width:100%;height:420px;overflow:hidden;padding:0;border:none; }
    .hero-banner-img { width:100%;height:100%;object-fit:cover;object-position:center 60%;display:block; }
    .hero-banner-overlay { position:absolute;inset:0;background:linear-gradient(180deg, rgba(20,20,26,0) 55%, rgba(12,16,22,0.32) 100%); }
    .hero-avatar { width:104px;height:104px;border-radius:50%;object-fit:cover;border:4px solid var(--bg);box-shadow:0 6px 18px rgba(0,0,0,0.2);display:block;position:relative;z-index:2;margin:-60px 0 20px; }
    @media(max-width:700px){ .hero-banner{height:300px;} .hero-avatar{width:84px;height:84px;margin:-48px 0 18px;} }
    section { padding:56px 0;border-top:1px solid var(--border); }
    .section-label { font-family:var(--mono);font-size:12px;color:var(--text-3);letter-spacing:0.06em;text-transform:uppercase;margin-bottom:24px; }
    .map-embed { width:100%;height:640px;border:1px solid var(--border);border-radius:var(--radius-lg);overflow:hidden; }
    .map-embed iframe { width:100%;height:100%;border:none;display:block; }
    .map-caption { font-size:13px;color:var(--text-3);margin-top:10px;font-family:var(--mono); }
    .career-map-embed { width:100%;height:600px;border:1px solid var(--border);border-radius:var(--radius-lg);overflow:hidden;background:var(--map-placeholder-bg); }
    .career-map-embed iframe { width:100%;height:100%;border:none;display:block; }
    .domain-grid { display:grid;grid-template-columns:repeat(auto-fit,minmax(190px,1fr));gap:12px; }
    .domain-card { background:var(--surface);border:1px solid var(--border);border-radius:var(--radius-md);padding:20px;transition:border-color 0.15s,transform 0.15s; }
    .domain-card:hover { border-color:var(--border-md);transform:translateY(-2px); }
    .domain-icon { font-size:20px;margin-bottom:12px;display:block; }
    .domain-card h3 { font-size:16px;font-weight:500;margin-bottom:6px;letter-spacing:-0.01em; }
    .domain-card p { font-size:14px;color:var(--text-3);line-height:1.6; }
    .chapter-grid { display:grid;grid-template-columns:1fr 1fr;gap:14px;margin-bottom:36px; }
    @media(max-width:600px){.chapter-grid{grid-template-columns:1fr;}}
    .chapter-card { background:var(--surface);border:1px solid var(--border);border-radius:var(--radius-md);padding:20px 22px; }
    .chapter-card.featured { border-color:var(--accent-border); }
    .chapter-card.pivot-card { border-color:var(--pivot-border); }
    .chapter-badge { display:inline-block;font-size:11px;font-family:var(--mono);padding:3px 9px;border-radius:100px;margin-bottom:10px; }
    .chapter-badge.current { background:var(--accent-lt);color:var(--accent); }
    .chapter-badge.pivot { background:var(--pivot-lt);color:var(--pivot); }
    .chapter-card h3 { font-size:16px;font-weight:500;letter-spacing:-0.01em;margin-bottom:3px; }
    .chapter-card .org { font-size:14px;color:var(--text-3);margin-bottom:12px; }
    .tag-row { display:flex;gap:6px;flex-wrap:wrap; }
    .tag { font-size:11px;font-family:var(--mono);padding:3px 7px;border-radius:4px;background:var(--bg);color:var(--text-3);border:1px solid var(--border); }
    .stack-compare { display:grid;grid-template-columns:1fr 40px 1fr;gap:0;align-items:start; }
    .stack-col-label { font-family:var(--mono);font-size:11px;color:var(--text-3);letter-spacing:0.04em;margin-bottom:10px; }
    .stack-col { display:flex;flex-direction:column;gap:6px; }
    .stack-item { font-family:var(--mono);font-size:13px;padding:8px 12px;border-radius:var(--radius-sm);border:1px solid var(--border); }
    .stack-item.old { background:var(--stack-old-bg);color:var(--text-3); }
    .stack-item.new { background:var(--stack-new-bg);color:var(--stack-new-text);border-color:var(--stack-new-border); }
    .stack-arrow-col { display:flex;align-items:center;justify-content:center;padding-top:30px;color:var(--text-3);font-size:20px; }
    .portfolio-grid { display:grid;grid-template-columns:repeat(auto-fill,minmax(240px,1fr));gap:14px; }
    .port-card { background:var(--surface);border:1px solid var(--border);border-radius:var(--radius-md);overflow:hidden;text-decoration:none;color:inherit;transition:border-color 0.15s,transform 0.15s;display:block; }
    .port-card:hover { border-color:var(--border-md);transform:translateY(-2px); }
    .port-thumb { height:72px;background:var(--bg);display:flex;align-items:center;justify-content:center;font-size:24px;border-bottom:1px solid var(--border); }
    .port-info { padding:12px 14px; }
    .port-info h3 { font-size:15px;font-weight:500;margin-bottom:3px; }
    .port-info p { font-size:13px;color:var(--text-3); }
    .port-card.see-all .port-thumb { font-size:14px;color:var(--text-3); }
    footer { border-top:1px solid var(--border);padding:36px 0; }
    footer .inner { max-width:900px;margin:0 auto;padding:0 24px;display:flex;justify-content:space-between;align-items:center;flex-wrap:wrap;gap:16px; }
    footer .name { font-size:16px;font-weight:500;color:var(--text-1); }
    footer .name span { color:var(--text-3);font-weight:300; }
    footer .links { display:flex;gap:20px; }
    footer .links a { font-size:15px;color:var(--text-3);text-decoration:none;transition:color 0.15s; }
    footer .links a:hover { color:var(--text-1); }
    .visitor-badge { display:block;margin-top:14px;opacity:0.7;height:20px; }
    .divider { border:none;border-top:1px solid var(--border);margin:32px 0; }
    @media(max-width:600px){.hero{padding:48px 0 36px;}.stack-compare{grid-template-columns:1fr;}.stack-arrow-col{display:none;}}'

# ── 共用頁面零件 ──────────────────────────────────────────────────────────────
# 首頁、專業領域、職涯、作品集、文章都用同一組 head / 導覽列 / 頁尾 / script。
# prefix：頁面放在子資料夾時（例如 articles/）要給 "../" 才連得回根目錄。

css_shared <- '
    nav .inner { flex-wrap:wrap;row-gap:8px; }
    .nav-links { display:flex;align-items:center;gap:28px; }
    nav a { font-size:14px;color:var(--text-3);text-decoration:none;transition:color 0.15s; }
    nav a:hover, nav a.active { color:var(--text-1); }
    nav a.active { font-weight:500; }
    .page-head { padding:56px 0 8px;border:none; }
    .page-head .eyebrow { font-family:var(--mono);font-size:12px;color:var(--text-3);letter-spacing:0.04em;margin-bottom:14px; }
    .page-head h1 { font-size:clamp(28px,4.5vw,42px);font-weight:300;letter-spacing:-0.03em;line-height:1.2;color:var(--text-1); }
    .explore-grid { display:grid;grid-template-columns:repeat(auto-fit,minmax(230px,1fr));gap:14px; }
    .explore-card { background:var(--surface);border:1px solid var(--border);border-radius:var(--radius-md);padding:20px 22px;text-decoration:none;color:inherit;display:block;transition:border-color 0.15s,transform 0.15s; }
    .explore-card:hover { border-color:var(--accent-border);transform:translateY(-2px); }
    .explore-card .icon { font-size:20px;display:block;margin-bottom:10px; }
    .explore-card h3 { font-size:17px;font-weight:500;letter-spacing:-0.01em;margin-bottom:6px; }
    .explore-card p { font-size:14px;color:var(--text-3);line-height:1.6; }
    .explore-card .go { font-size:13px;color:var(--accent);margin-top:12px;display:block; }
    @media(max-width:640px){ nav .inner{gap:12px;} .nav-links{order:3;width:100%;gap:20px;overflow-x:auto;} .nav-logo span{display:none;} }'

# 作品集頁（map_list.html）的精選集卡片，樣式跟原本首頁的一樣
css_portfolio <- '
    .portfolio-grid { display:grid;grid-template-columns:repeat(auto-fill,minmax(240px,1fr));gap:14px; }
    .port-card { background:var(--surface);border:1px solid var(--border);border-radius:var(--radius-md);overflow:hidden;text-decoration:none;color:inherit;transition:border-color 0.15s,transform 0.15s;display:block; }
    .port-card:hover { border-color:var(--border-md);transform:translateY(-2px); }
    .port-thumb { height:72px;background:var(--bg);display:flex;align-items:center;justify-content:center;font-size:24px;border-bottom:1px solid var(--border); }
    .port-info { padding:12px 14px; }
    .port-info h3 { font-size:15px;font-weight:500;margin-bottom:3px; }
    .port-info p { font-size:13px;color:var(--text-3); }'

css <- paste0(css, css_shared)

page_head <- function(title, description, page_css) {
  c(
    "<!DOCTYPE html>",
    '<html lang="en">',
    "<head>",
    '  <meta charset="utf-8">',
    '  <meta name="viewport" content="width=device-width, initial-scale=1">',
    '  <meta name="color-scheme" content="light dark">',
    # Applied synchronously, before CSS/paint, so a saved dark-mode choice
    # doesn't flash light first on reload.
    "  <script>(function(){try{var t=localStorage.getItem(\"wy_theme\");if(t)document.documentElement.setAttribute(\"data-theme\",t);}catch(e){}})();</script>",
    paste0("  <title>", title, "</title>"),
    paste0('  <meta name="description" content="', description, '">'),
    '  <link rel="preconnect" href="https://fonts.googleapis.com">',
    '  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>',
    '  <link href="https://fonts.googleapis.com/css2?family=DM+Sans:ital,opsz,wght@0,9..40,300;0,9..40,400;0,9..40,500;1,9..40,300&family=DM+Mono:wght@400;500&family=LXGW+WenKai+TC:wght@300;400;700&display=swap" rel="stylesheet">',
    "  <style>",
    page_css,
    "  </style>",
    "</head>",
    "<body>",
    ""
  )
}

# active = 目前所在的頁面（expertise / career / portfolio），導覽列會標亮
site_nav <- function(active = "", prefix = "") {
  nav_link <- function(key, href) {
    cls <- if (key == active) ' class="active" aria-current="page"' else ""
    en <- nav[[paste0(key, "_en")]]
    zh <- nav[[paste0(key, "_zh")]]
    paste0('        <a href="', href, '"', cls, " ", i18n(en, zh), ">", en, "</a>")
  }
  c(
    "  <nav>",
    '    <div class="inner">',
    paste0('      <a class="nav-logo" href="', prefix, 'index.html">Wilson Yung <span>雍士賢</span></a>'),
    '      <div class="nav-links">',
    nav_link("expertise", paste0(prefix, "expertise.html")),
    nav_link("career",    paste0(prefix, "career.html")),
    nav_link("portfolio", paste0(prefix, "map_list.html")),
    nav_link("contact",   "#contact"),
    "      </div>",
    '      <button class="theme-toggle" id="themeToggle" aria-label="切換深色模式">🌙</button>',
    '      <button class="lang-toggle" id="langToggle" aria-label="切換為繁體中文">繁中</button>',
    "    </div>",
    "  </nav>",
    ""
  )
}

# 頁尾就是「聯絡」，每一頁都有 id="contact"，導覽列的聯絡連結跳到這裡
site_footer <- function(badge_path, prefix = "") {
  c(
    '  <footer id="contact">',
    '    <div class="inner">',
    "      <div>",
    '        <p class="name">Wilson Shih-Hsien Yung <span>雍士賢</span></p>',
    paste0('        <p style="font-size:12px;color:var(--text-3);margin-top:3px;" ', i18n(ftr$tagline_en, ftr$tagline_zh), ">", ftr$tagline_en, "</p>"),
    "      </div>",
    '      <div class="links">',
    paste0('        <a href="mailto:', ftr$email, '">Email</a>'),
    paste0('        <a href="', ftr$linkedin, '" target="_blank" rel="noopener">LinkedIn</a>'),
    paste0('        <a href="', prefix, 'map_list.html" ', i18n(ftr$portfolio_en, ftr$portfolio_zh), ">", ftr$portfolio_en, "</a>"),
    "      </div>",
    "    </div>",
    visitor_badge(badge_path),
    "  </footer>",
    ""
  )
}

# 專業領域、職涯頁面的標題區
page_header <- function(eyebrow_en, eyebrow_zh, h1_en, h1_zh) {
  c(
    '  <div class="container">',
    '    <section class="page-head">',
    paste0('      <p class="eyebrow" ', i18n(eyebrow_en, eyebrow_zh), ">", eyebrow_en, "</p>"),
    paste0("      <h1 ", i18n(h1_en, h1_zh), ">", h1_en, "</h1>"),
    "    </section>",
    "  </div>",
    ""
  )
}

explore_card <- function(e) {
  paste0(
    '\n        <a class="explore-card" href="', e$url, '">',
    '\n          <span class="icon">', e$icon, "</span>",
    "\n          <h3 ", i18n(e$title_en, e$title_zh), ">", e$title_en, "</h3>",
    "\n          <p ", i18n(e$desc_en, e$desc_zh), ">", e$desc_en, "</p>",
    '\n          <span class="go">→</span>',
    "\n        </a>"
  )
}

site_script <- c(
  "  <script>",
  '    var currentLang = localStorage.getItem("wy_lang") || "en";',
  "    function applyLang(lang) {",
  "      currentLang = lang;",
  '      localStorage.setItem("wy_lang", lang);',
  '      document.documentElement.lang = lang === "zh" ? "zh-TW" : "en";',
  '      document.querySelectorAll("[data-i18n]").forEach(function(el) {',
  '        var text = el.getAttribute("data-" + lang);',
  "        if (text) { if (el.tagName === 'IMG') el.alt = text; else el.innerHTML = text; }",
  "      });",
  '      var btn = document.getElementById("langToggle");',
  '      btn.textContent = lang === "zh" ? "EN" : "\u7e41\u4e2d";',
  '      btn.setAttribute("aria-label", lang === "zh" ? "Switch to English" : "\u5207\u63db\u70ba\u7e41\u9ad4\u4e2d\u6587");',
  "    }",
  '    document.getElementById("langToggle").addEventListener("click", function() {',
  '      applyLang(currentLang === "en" ? "zh" : "en");',
  "    });",
  "    applyLang(currentLang);",
  "",
  '    function systemPrefersDark() {',
  '      return window.matchMedia && window.matchMedia("(prefers-color-scheme: dark)").matches;',
  "    }",
  '    function isDarkActive() {',
  '      var forced = document.documentElement.getAttribute("data-theme");',
  '      return forced === "dark" || (!forced && systemPrefersDark());',
  "    }",
  '    function updateThemeBtn() {',
  '      var themeBtn = document.getElementById("themeToggle");',
  "      var dark = isDarkActive();",
  '      themeBtn.textContent = dark ? "☀️" : "🌙";',
  '      themeBtn.setAttribute("aria-label", dark ? "Switch to light mode" : "Switch to dark mode");',
  "    }",
  '    var savedTheme = localStorage.getItem("wy_theme");',
  "    if (savedTheme) document.documentElement.setAttribute(\"data-theme\", savedTheme);",
  "    updateThemeBtn();",
  '    document.getElementById("themeToggle").addEventListener("click", function() {',
  "      var next = isDarkActive() ? \"light\" : \"dark\";",
  '      document.documentElement.setAttribute("data-theme", next);',
  '      localStorage.setItem("wy_theme", next);',
  "      updateThemeBtn();",
  "    });",
  "  </script>"
)

# ── index.html（首頁）────────────────────────────────────────────────────────
explore_cards_html <- paste(lapply(c_$explore$cards, explore_card), collapse = "")

lines <- c(
  page_head(c_$meta$title_en, c_$meta$description_en, css),
  site_nav(),
  '  <section class="hero-banner" id="top">',
  paste0('    <img class="hero-banner-img" src="', hero$photo, '" ',
         i18n(hero$photo_alt_en, hero$photo_alt_zh), " ",
         'alt="', hero$photo_alt_en, '" loading="eager">'),
  '    <div class="hero-banner-overlay"></div>',
  "  </section>",
  "",
  '  <div class="container">',
  '    <section class="hero" style="border:none;padding-bottom:48px;">',
  paste0('      <img class="hero-avatar" src="', hero$avatar, '" ',
         i18n(hero$avatar_alt_en, hero$avatar_alt_zh), " ",
         'alt="', hero$avatar_alt_en, '" loading="eager">'),
  paste0('      <p class="hero-eyebrow" ', i18n(hero$eyebrow_en, hero$eyebrow_zh), ">", hero$eyebrow_en, "</p>"),
  "      <h1>",
  paste0("        <span ", i18n(hero$h1_line1_en, hero$h1_line1_zh), ">", hero$h1_line1_en, "</span><br>"),
  paste0("        <em ", i18n(hero$h1_em_en, hero$h1_em_zh), ">", hero$h1_em_en, "</em>"),
  "      </h1>",
  paste0('      <p class="hero-desc" ', i18n(hero$desc_en, hero$desc_zh), ">", hero$desc_en, "</p>"),
  '      <div class="chip-row">',
  paste0("        ", chips_accent_html),
  paste0("        ", chips_domain_html),
  "      </div>",
  "    </section>",
  "  </div>",
  "",
  '  <div class="container">',
  '    <section id="footprint" style="padding-top:0;border:none;">',
  paste0('      <p class="section-label" ', i18n(fp$label_en, fp$label_zh), ">", fp$label_en, "</p>"),
  '      <div class="map-embed">',
  paste0('        <iframe src="', fp$iframe_src, '" title="Wilson Yung personal movement footprint" loading="lazy" allow="fullscreen"></iframe>'),
  "      </div>",
  paste0('      <p class="map-caption" ', i18n(fp$caption_en, fp$caption_zh), ">", fp$caption_en, "</p>"),
  "    </section>",
  "  </div>",
  "",
  '  <div class="container">',
  '    <section id="explore">',
  paste0('      <p class="section-label" ', i18n(c_$explore$label_en, c_$explore$label_zh), ">", c_$explore$label_en, "</p>"),
  '      <div class="explore-grid">',
  explore_cards_html,
  "      </div>",
  "    </section>",
  "  </div>",
  "",
  site_footer(""),
  site_script,
  "",
  "</body>",
  "</html>"
)

writeLines(lines, "index.html", useBytes = TRUE)
message("\u2713 index.html \u5df2\u7522\u751f")

# ── expertise.html（專業領域）────────────────────────────────────────────────
lines_exp <- c(
  page_head(paste0(nav$expertise_en, " \u2014 Wilson Yung"), c_$meta$description_en, css),
  site_nav(active = "expertise"),
  page_header(nav$expertise_en, nav$expertise_zh, exp$label_en, exp$label_zh),
  '  <div class="container">',
  '    <section style="border:none;padding-top:24px;">',
  '      <div class="domain-grid">',
  domain_cards_html,
  "      </div>",
  "    </section>",
  "  </div>",
  "",
  site_footer("expertise.html"),
  site_script,
  "",
  "</body>",
  "</html>"
)

writeLines(lines_exp, "expertise.html", useBytes = TRUE)
message("\u2713 expertise.html \u5df2\u7522\u751f")

# ── career.html（工作歷程）────────────────────────────────────────────────────
lines_car <- c(
  page_head(paste0(nav$career_en, " \u2014 Wilson Yung"), c_$meta$description_en, css),
  site_nav(active = "career"),
  page_header(nav$career_en, nav$career_zh, car$label_en, car$label_zh),
  '  <div class="container">',
  '    <section style="border:none;padding-top:24px;">',
  '      <div class="chapter-grid">',
  chapter_cards_html,
  "      </div>",
  '      <hr class="divider">',
  paste0('      <p class="section-label" style="margin-bottom:20px;" ', i18n(car$stack_label_en, car$stack_label_zh), ">", car$stack_label_en, "</p>"),
  '      <div class="stack-compare">',
  "        <div>",
  paste0('          <p class="stack-col-label" ', i18n(car$before_label_en, car$before_label_zh), ">", car$before_label_en, "</p>"),
  '          <div class="stack-col">',
  paste0("            ", stack_items(car$stack_before, car$stack_before_zh, "old")),
  "          </div>",
  "        </div>",
  '        <div class="stack-arrow-col">\u2192</div>',
  "        <div>",
  paste0('          <p class="stack-col-label" ', i18n(car$after_label_en, car$after_label_zh), ">", car$after_label_en, "</p>"),
  '          <div class="stack-col">',
  paste0("            ", stack_items(car$stack_after, car$stack_after_zh, "new")),
  "          </div>",
  "        </div>",
  "      </div>",
  '      <hr class="divider">',
  paste0('      <p class="section-label" style="margin-bottom:12px;" ', i18n(car$career_map_label_en, car$career_map_label_zh), ">", car$career_map_label_en, "</p>"),
  '      <div class="career-map-embed">',
  paste0('        <iframe src="', car$career_map_src, '" title="Wilson Yung career locations" loading="lazy" allow="fullscreen"></iframe>'),
  "      </div>",
  "    </section>",
  "  </div>",
  "",
  site_footer("career.html"),
  site_script,
  "",
  "</body>",
  "</html>"
)

writeLines(lines_car, "career.html", useBytes = TRUE)
message("\u2713 career.html \u5df2\u7522\u751f")

# \u2500\u2500 map_list.html\uff08\u5b8c\u6574\u4f5c\u54c1\u96c6\uff09\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500

ml <- c_$map_list

css_map <- '    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
    :root {
      --bg:#f7f6f2;--surface:#ffffff;--border:rgba(0,0,0,0.08);--border-md:rgba(0,0,0,0.13);
      --text-1:#1a1917;--text-2:#4a4845;--text-3:#8a8784;
      --accent:#2B5F8E;--accent-lt:#e8f0f8;--accent-border:#b8cfe4;
      --pivot:#C4783A;--pivot-lt:#fdf0e6;--pivot-border:#e8c9a8;
      --nav-bg:rgba(247,246,242,0.88);--map-placeholder-bg:#eef2f6;
      --stack-old-bg:#f5f4f0;--stack-new-bg:#edf4ee;--stack-new-text:#2d6b35;--stack-new-border:#c8dfc9;
      --mono:"DM Mono","LXGW WenKai TC",monospace;--sans:"DM Sans","LXGW WenKai TC",system-ui,sans-serif;
      --radius-sm:6px;--radius-md:10px;--radius-lg:16px;
    }
    @media(prefers-color-scheme:dark){
      :root:not([data-theme="light"]) {
        --bg:#15151a;--surface:#1e1e25;--border:rgba(255,255,255,0.08);--border-md:rgba(255,255,255,0.14);
        --text-1:#f0efec;--text-2:#b7b4ad;--text-3:#7d7a73;
        --accent:#6FA8D8;--accent-lt:rgba(111,168,216,0.14);--accent-border:rgba(111,168,216,0.35);
        --pivot:#E0985C;--pivot-lt:rgba(224,152,92,0.14);--pivot-border:rgba(224,152,92,0.35);
        --nav-bg:rgba(21,21,26,0.85);--map-placeholder-bg:#1c1c22;
        --stack-old-bg:#232228;--stack-new-bg:rgba(76,175,120,0.14);--stack-new-text:#6fcf97;--stack-new-border:rgba(111,207,151,0.35);
      }
    }
    :root[data-theme="dark"] {
      --bg:#15151a;--surface:#1e1e25;--border:rgba(255,255,255,0.08);--border-md:rgba(255,255,255,0.14);
      --text-1:#f0efec;--text-2:#b7b4ad;--text-3:#7d7a73;
      --accent:#6FA8D8;--accent-lt:rgba(111,168,216,0.14);--accent-border:rgba(111,168,216,0.35);
      --pivot:#E0985C;--pivot-lt:rgba(224,152,92,0.14);--pivot-border:rgba(224,152,92,0.35);
      --nav-bg:rgba(21,21,26,0.85);--map-placeholder-bg:#1c1c22;
      --stack-old-bg:#232228;--stack-new-bg:rgba(76,175,120,0.14);--stack-new-text:#6fcf97;--stack-new-border:rgba(111,207,151,0.35);
    }
    html { scroll-behavior: smooth; }
    body { font-family:var(--sans);background:var(--bg);color:var(--text-1);font-size:17px;line-height:1.7;-webkit-font-smoothing:antialiased;transition:background-color 0.25s ease,color 0.25s ease; }
    .container { max-width:960px;margin:0 auto;padding:0 24px; }
    nav { position:sticky;top:0;z-index:100;background:var(--nav-bg);backdrop-filter:blur(12px);border-bottom:1px solid var(--border);padding:14px 0;transition:background-color 0.25s ease,border-color 0.25s ease; }
    nav .inner { max-width:960px;margin:0 auto;padding:0 24px;display:flex;align-items:center;gap:28px; }
    .nav-logo { font-size:15px;font-weight:500;color:var(--text-1);text-decoration:none;margin-right:auto;letter-spacing:-0.01em; }
    .nav-logo span { color:var(--text-3);font-weight:300; }
    nav a.back { font-size:14px;color:var(--text-3);text-decoration:none;transition:color 0.15s;display:flex;align-items:center;gap:6px; }
    nav a.back:hover { color:var(--text-1); }
    .lang-toggle { font-family:var(--mono);font-size:11px;font-weight:500;padding:5px 12px;border-radius:100px;border:1.5px solid var(--accent);background:var(--accent-lt);color:var(--accent);cursor:pointer;transition:all 0.2s;white-space:nowrap;flex-shrink:0;letter-spacing:0.03em; }
    .lang-toggle:hover { background:var(--accent);color:#ffffff;border-color:var(--accent); }
    .theme-toggle { font-size:14px;width:32px;height:32px;border-radius:50%;border:1.5px solid var(--accent);background:var(--accent-lt);color:var(--accent);cursor:pointer;transition:all 0.2s;display:flex;align-items:center;justify-content:center;flex-shrink:0;padding:0;line-height:1; }
    .theme-toggle:hover { background:var(--accent);color:#ffffff;border-color:var(--accent); }
    .hero { padding:56px 0 40px; }
    .hero-eyebrow { font-family:var(--mono);font-size:12px;color:var(--text-3);letter-spacing:0.04em;margin-bottom:16px; }
    .hero h1 { font-size:clamp(28px,4.5vw,42px);font-weight:300;letter-spacing:-0.03em;line-height:1.2;color:var(--text-1);margin-bottom:14px; }
    .hero-desc { font-size:16px;color:var(--text-2);max-width:600px; }
    section { padding:44px 0;border-top:1px solid var(--border); }
    .section-head { display:flex;align-items:baseline;justify-content:space-between;gap:16px;margin-bottom:20px;flex-wrap:wrap; }
    .section-label { font-family:var(--mono);font-size:12px;color:var(--text-3);letter-spacing:0.06em;text-transform:uppercase; }
    .section-count { font-family:var(--mono);font-size:12px;color:var(--text-3); }
    .map-grid { display:grid;grid-template-columns:repeat(auto-fill,minmax(260px,1fr));gap:12px; }
    .map-card { background:var(--surface);border:1px solid var(--border);border-radius:var(--radius-md);padding:16px 18px;display:flex;flex-direction:column;gap:8px;transition:border-color 0.15s,transform 0.15s; }
    .map-card:hover { border-color:var(--border-md);transform:translateY(-2px); }
    .map-card-top { display:flex;align-items:center;justify-content:space-between;gap:8px; }
    .map-badge { font-family:var(--mono);font-size:11px;padding:3px 9px;border-radius:100px;background:var(--accent-lt);color:var(--accent);white-space:nowrap; }
    .map-tool { font-family:var(--mono);font-size:11px;color:var(--text-3);white-space:nowrap; }
    .map-title { font-size:15px;font-weight:500;letter-spacing:-0.01em;color:var(--text-1);line-height:1.4; }
    .map-links { display:flex;flex-direction:column;gap:4px;margin-top:2px; }
    .map-links a { font-size:13px;color:var(--accent);text-decoration:none;display:inline-flex;align-items:center;gap:4px; }
    .map-links a:hover { text-decoration:underline; }
    .map-links a .arrow { transition:transform 0.15s; }
    .map-links a:hover .arrow { transform:translateX(2px); }
    .note { font-size:14px;color:var(--text-3);margin-top:20px; }
    .note a { color:var(--accent);text-decoration:none; }
    .note a:hover { text-decoration:underline; }
    footer { border-top:1px solid var(--border);padding:36px 0; }
    footer .inner { max-width:960px;margin:0 auto;padding:0 24px;display:flex;justify-content:space-between;align-items:center;flex-wrap:wrap;gap:16px; }
    footer .name { font-size:16px;font-weight:500;color:var(--text-1); }
    footer .name span { color:var(--text-3);font-weight:300; }
    footer .links { display:flex;gap:20px; }
    footer .links a { font-size:15px;color:var(--text-3);text-decoration:none;transition:color 0.15s; }
    footer .links a:hover { color:var(--text-1); }
    .visitor-badge { display:block;margin-top:14px;opacity:0.7;height:20px; }
    @media(max-width:600px){ .hero{padding:40px 0 32px;} .map-grid{grid-template-columns:1fr;} }'

map_sections_html <- paste(lapply(ml$sections, map_section), collapse = "\n")

css_map <- paste0(css_map, css_shared, css_portfolio)

lines2 <- c(
  page_head(ml$meta_title, ml$meta_description, css_map),
  site_nav(active = "portfolio"),
  '  <div class="container">',
  '    <section class="hero" style="border:none;padding-bottom:24px;">',
  paste0('      <p class="hero-eyebrow" ', i18n(ml$hero_eyebrow_en, ml$hero_eyebrow_zh), ">", ml$hero_eyebrow_en, "</p>"),
  paste0("      <h1 ", i18n(ml$hero_title_en, ml$hero_title_zh), ">", ml$hero_title_en, "</h1>"),
  paste0('      <p class="hero-desc" ', i18n(ml$hero_desc_en, ml$hero_desc_zh), ">", ml$hero_desc_en, "</p>"),
  "    </section>",
  "  </div>",
  '  <div class="container">',
  '    <section id="selected">',
  '      <div class="section-head">',
  paste0('        <p class="section-label" ', i18n(port$label_en, port$label_zh), ">", port$label_en, "</p>"),
  "      </div>",
  '      <div class="portfolio-grid">',
  port_cards_html,
  "      </div>",
  "    </section>",
  "  </div>",
  map_sections_html,
  "",
  site_footer("map_list.html"),
  site_script,
  "",
  "</body>",
  "</html>"
)

writeLines(lines2, "map_list.html", useBytes = TRUE)
message("\u2713 map_list.html \u5df2\u7522\u751f")

# ── articles/<slug>.html（文章）──────────────────────────────────────────────
# 內容在 articles.R。文章放在 articles/ 子資料夾，所以連回根目錄的路徑都要加 ../

source("script/articles.R")

css_article <- paste0(css_map, '
    .article { max-width:720px; }
    .article-toc { display:flex;flex-wrap:wrap;gap:8px;margin-top:24px; }
    .article-toc a { font-family:var(--mono);font-size:12px;padding:5px 11px;border-radius:100px;border:1px solid var(--accent-border);background:var(--accent-lt);color:var(--accent);text-decoration:none; }
    .article-toc a:hover { background:var(--accent);color:#ffffff; }
    .article-body h2 { font-size:clamp(22px,3.5vw,28px);font-weight:400;letter-spacing:-0.02em;line-height:1.3;margin:0 0 4px;scroll-margin-top:80px; }
    .article-body h2:not(:first-child) { margin-top:64px;padding-top:44px;border-top:1px solid var(--border); }
    .article-body .post-date { font-family:var(--mono);font-size:12px;color:var(--text-3);margin-bottom:24px; }
    .article-body h3 { font-size:18px;font-weight:500;letter-spacing:-0.01em;margin:36px 0 10px; }
    .article-body p { color:var(--text-2);margin-bottom:18px; }
    .article-body ul { color:var(--text-2);margin:0 0 18px;padding-left:22px; }
    .article-body ul.plain { list-style:none;padding-left:0; }
    .article-body li { margin-bottom:8px; }
    .article-body a { color:var(--accent);text-decoration:none; }
    .article-body a:hover { text-decoration:underline; }
    .article-body figure { margin:28px 0; }
    .article-body figure img { width:100%;height:auto;display:block;border-radius:var(--radius-md);border:1px solid var(--border); }
    .article-body figcaption { font-family:var(--mono);font-size:12px;color:var(--text-3);margin-top:10px;line-height:1.6; }
    .post-links { display:flex;flex-wrap:wrap;gap:8px 22px;margin-top:28px;padding:14px 0;border-top:1px solid var(--border);border-bottom:1px solid var(--border);font-size:14px; }
    .article-outro { font-size:15px;color:var(--text-3);margin-top:56px; }
    .article-outro a { color:var(--accent);text-decoration:none; }
    .article-outro a:hover { text-decoration:underline; }')

post_link <- function(url, icon, en, zh) {
  if (is.null(url)) return(NULL)
  paste0('<a href="', url, '" target="_blank" rel="noopener">', icon, ' <span ', i18n(en, zh), ">", en, "</span> →</a>")
}

# 圖片寫上實際寬高，讓瀏覽器在 lazy 載入前先預留空間；
# 不然點目錄錨點時，上方圖片載入後會把內容往下推，第一次跳轉會跑掉
img_size_attr <- function(src) {
  info <- magick::image_info(magick::image_read(src))
  paste0('width="', info$width, '" height="', info$height, '" ')
}

article_block <- function(b) {
  switch(b$type,
    h2   = paste0('\n      <h2 id="', b$id, '" ', i18n(b$en, b$zh), ">", b$en, "</h2>"),
    date = paste0('\n      <p class="post-date" ', i18n(b$en, b$zh), ">", b$en, "</p>"),
    h3   = paste0("\n      <h3 ", i18n(b$en, b$zh), ">", b$en, "</h3>"),
    p    = paste0("\n      <p ", i18n(b$en, b$zh), ">", b$en, "</p>"),
    ul   = paste0(
      "\n      <ul", if (isTRUE(b$plain)) ' class="plain"' else "", ">",
      paste(lapply(b$items, function(it) paste0("\n        <li ", i18n(it$en, it$zh), ">", it$en, "</li>")), collapse = ""),
      "\n      </ul>"
    ),
    img  = paste0(
      "\n      <figure>",
      '\n        <img src="../', b$src, '" ', img_size_attr(b$src), i18n(b$alt_en, b$alt_zh), ' alt="', b$alt_en, '" loading="lazy">',
      if (!is.null(b$cap_en)) paste0("\n        <figcaption ", i18n(b$cap_en, b$cap_zh), ">", b$cap_en, "</figcaption>") else "",
      "\n      </figure>"
    ),
    links = paste0(
      '\n      <div class="post-links">\n        ',
      paste(c(post_link(b$map,  "🗺️", "Interactive map", "互動地圖"),
              post_link(b$code, "💻", "Code",            "程式碼"),
              post_link(b$post, "💬", "LinkedIn post",   "LinkedIn 貼文")), collapse = "\n        "),
      "\n      </div>"
    )
  )
}

article_toc <- function(blocks) {
  h2s <- Filter(function(b) b$type == "h2" && !is.null(b$id), blocks)
  if (length(h2s) == 0) return(NULL)
  paste0(
    '      <div class="article-toc">',
    paste(lapply(h2s, function(b) paste0('\n        <a href="#', b$id, '" ', i18n(b$en, b$zh), ">", b$en, "</a>")), collapse = ""),
    "\n      </div>"
  )
}

dir.create("articles", showWarnings = FALSE)

for (a in articles) {
  lines3 <- c(
    page_head(a$meta_title, a$meta_description, css_article),
    site_nav(prefix = "../"),
    '  <div class="container article">',
    '    <section class="hero" style="border:none;padding-bottom:8px;">',
    paste0('      <p class="hero-eyebrow" ', i18n(a$eyebrow_en, a$eyebrow_zh), ">", a$eyebrow_en, "</p>"),
    paste0("      <h1 ", i18n(a$title_en, a$title_zh), ">", a$title_en, "</h1>"),
    paste0('      <p class="hero-desc" ', i18n(a$lede_en, a$lede_zh), ">", a$lede_en, "</p>"),
    article_toc(a$blocks),
    "    </section>",
    '    <section class="article-body">',
    paste(lapply(a$blocks, article_block), collapse = ""),
    paste0('\n      <p class="article-outro" ', i18n(a$outro_en, a$outro_zh), ">", a$outro_en, "</p>"),
    "    </section>",
    "  </div>",
    "",
    site_footer(paste0("articles%2F", a$slug, ".html"), prefix = "../"),
    site_script,
    # 帶錨點開頁面時，smooth scroll 動畫進行中字型才載完，版面一動動畫就停在半路。
    # 等字型和頁面都載完後再直接對準一次（使用者已經自己捲動的話就不動）。
    "  <script>",
    "    (function() {",
    "      if (!location.hash) return;",
    "      var userMoved = false;",
    '      ["wheel", "touchstart", "keydown"].forEach(function(ev) {',
    "        window.addEventListener(ev, function() { userMoved = true; }, { once: true, passive: true });",
    "      });",
    "      function realign() {",
    "        if (userMoved) return;",
    "        var el = document.getElementById(decodeURIComponent(location.hash.slice(1)));",
    '        if (el) el.scrollIntoView({ behavior: "instant" });',
    "      }",
    "      if (document.fonts) document.fonts.ready.then(realign);",
    '      window.addEventListener("load", realign);',
    "    })();",
    "  </script>",
    "",
    "</body>",
    "</html>"
  )
  out <- file.path("articles", paste0(a$slug, ".html"))
  writeLines(lines3, out, useBytes = TRUE)
  message("✓ ", out, " 已產生")
}
