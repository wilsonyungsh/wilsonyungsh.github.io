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
      --accent:#2B5F8E;--accent-lt:#e8f0f8;--pivot:#C4783A;--pivot-lt:#fdf0e6;
      --mono:"DM Mono",monospace;--sans:"DM Sans",system-ui,sans-serif;
      --radius-sm:6px;--radius-md:10px;--radius-lg:16px;
    }
    html { scroll-behavior: smooth; }
    body { font-family:var(--sans);background:var(--bg);color:var(--text-1);font-size:17px;line-height:1.7;-webkit-font-smoothing:antialiased; }
    .container { max-width:900px;margin:0 auto;padding:0 24px; }
    nav { position:sticky;top:0;z-index:100;background:rgba(247,246,242,0.88);backdrop-filter:blur(12px);border-bottom:1px solid var(--border);padding:14px 0; }
    nav .inner { max-width:900px;margin:0 auto;padding:0 24px;display:flex;align-items:center;gap:28px; }
    .nav-logo { font-size:15px;font-weight:500;color:var(--text-1);text-decoration:none;margin-right:auto;letter-spacing:-0.01em; }
    .nav-logo span { color:var(--text-3);font-weight:300; }
    nav a { font-size:14px;color:var(--text-3);text-decoration:none;transition:color 0.15s; }
    nav a:hover { color:var(--text-1); }
    .lang-toggle { font-family:var(--mono);font-size:11px;font-weight:500;padding:5px 12px;border-radius:100px;border:1.5px solid var(--accent);background:var(--accent-lt);color:var(--accent);cursor:pointer;transition:all 0.2s;white-space:nowrap;flex-shrink:0;letter-spacing:0.03em; }
    .lang-toggle:hover { background:var(--accent);color:#ffffff;border-color:var(--accent); }
    .hero { padding:72px 0 56px; }
    .hero-eyebrow { font-family:var(--mono);font-size:12px;color:var(--text-3);letter-spacing:0.04em;margin-bottom:16px; }
    .hero h1 { font-size:clamp(32px,5vw,48px);font-weight:300;letter-spacing:-0.03em;line-height:1.15;color:var(--text-1);margin-bottom:20px; }
    .hero h1 em { font-style:italic;color:var(--text-3); }
    .hero-desc { font-size:18px;color:var(--text-2);max-width:560px;margin-bottom:28px;line-height:1.75; }
    .chip-row { display:flex;flex-wrap:wrap;gap:8px; }
    .chip { font-family:var(--mono);font-size:11px;padding:5px 11px;border-radius:100px;border:1px solid var(--border-md);color:var(--text-2);background:var(--surface);white-space:nowrap; }
    .chip.accent { background:var(--accent-lt);border-color:#b8cfe4;color:var(--accent); }
    section { padding:56px 0;border-top:1px solid var(--border); }
    .section-label { font-family:var(--mono);font-size:12px;color:var(--text-3);letter-spacing:0.06em;text-transform:uppercase;margin-bottom:24px; }
    .map-embed { width:100%;height:520px;border:1px solid var(--border);border-radius:var(--radius-lg);overflow:hidden; }
    .map-embed iframe { width:100%;height:100%;border:none;display:block; }
    .map-caption { font-size:13px;color:var(--text-3);margin-top:10px;font-family:var(--mono); }
    .career-map-embed { width:100%;height:420px;border:1px solid var(--border);border-radius:var(--radius-lg);overflow:hidden;background:#eef2f6; }
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
    .chapter-card.featured { border-color:#b8cfe4; }
    .chapter-card.pivot-card { border-color:#e8c9a8; }
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
    .stack-item.old { background:#f5f4f0;color:var(--text-3); }
    .stack-item.new { background:#edf4ee;color:#2d6b35;border-color:#c8dfc9; }
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
    .divider { border:none;border-top:1px solid var(--border);margin:32px 0; }
    @media(max-width:600px){.hero{padding:48px 0 36px;}.stack-compare{grid-template-columns:1fr;}.stack-arrow-col{display:none;}}'

# ── 組裝 HTML（用 paste0 拼接，避免 sprintf 限制）────────────────────────────
lines <- c(
  "<!DOCTYPE html>",
  '<html lang="en">',
  "<head>",
  '  <meta charset="utf-8">',
  '  <meta name="viewport" content="width=device-width, initial-scale=1">',
  paste0("  <title>", c_$meta$title_en, "</title>"),
  paste0('  <meta name="description" content="', c_$meta$description_en, '">'),
  '  <link rel="preconnect" href="https://fonts.googleapis.com">',
  '  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>',
  '  <link href="https://fonts.googleapis.com/css2?family=DM+Sans:ital,opsz,wght@0,9..40,300;0,9..40,400;0,9..40,500;1,9..40,300&family=DM+Mono:wght@400;500&display=swap" rel="stylesheet">',
  "  <style>",
  css,
  "  </style>",
  "</head>",
  "<body>",
  "",
  "  <nav>",
  '    <div class="inner">',
  '      <a class="nav-logo" href="#top">Wilson Yung <span>\u96cd\u58eb\u8ce2</span></a>',
  paste0('      <a href="#expertise" ', i18n(nav$expertise_en, nav$expertise_zh), ">", nav$expertise_en, "</a>"),
  paste0('      <a href="#career"    ', i18n(nav$career_en,    nav$career_zh),    ">", nav$career_en,    "</a>"),
  paste0('      <a href="#portfolio" ', i18n(nav$portfolio_en, nav$portfolio_zh), ">", nav$portfolio_en, "</a>"),
  paste0('      <a href="#contact"   ', i18n(nav$contact_en,   nav$contact_zh),   ">", nav$contact_en,   "</a>"),
  '      <button class="lang-toggle" id="langToggle" aria-label="\u5207\u63db\u70ba\u7e41\u9ad4\u4e2d\u6587">\u7e41\u4e2d</button>',
  "    </div>",
  "  </nav>",
  "",
  '  <div class="container">',
  '    <section class="hero" id="top" style="border:none;padding-bottom:48px;">',
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
  '    <section id="expertise">',
  paste0('      <p class="section-label" ', i18n(exp$label_en, exp$label_zh), ">", exp$label_en, "</p>"),
  '      <div class="domain-grid">',
  domain_cards_html,
  "      </div>",
  "    </section>",
  "  </div>",
  "",
  '  <div class="container">',
  '    <section id="career">',
  paste0('      <p class="section-label" ', i18n(car$label_en, car$label_zh), ">", car$label_en, "</p>"),
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
  '  <div class="container">',
  '    <section id="portfolio">',
  paste0('      <p class="section-label" ', i18n(port$label_en, port$label_zh), ">", port$label_en, "</p>"),
  '      <div class="portfolio-grid">',
  port_cards_html,
  paste0('        <a class="port-card see-all" href="', port$see_all_url, '" target="_blank" rel="noopener">'),
  paste0('          <div class="port-thumb" ', i18n(port$see_all_en, port$see_all_zh), ">", port$see_all_en, "</div>"),
  '          <div class="port-info">',
  paste0("            <h3 ", i18n(port$see_all_label_en, port$see_all_label_zh), ">", port$see_all_label_en, "</h3>"),
  "            <p>wilsonyungsh.github.io</p>",
  "          </div>",
  "        </a>",
  "      </div>",
  "    </section>",
  "  </div>",
  "",
  '  <footer id="contact">',
  '    <div class="inner">',
  "      <div>",
  '        <p class="name">Wilson Shih-Hsien Yung <span>\u96cd\u58eb\u8ce2</span></p>',
  paste0('        <p style="font-size:12px;color:var(--text-3);margin-top:3px;" ', i18n(ftr$tagline_en, ftr$tagline_zh), ">", ftr$tagline_en, "</p>"),
  "      </div>",
  '      <div class="links">',
  paste0('        <a href="mailto:', ftr$email, '">Email</a>'),
  paste0('        <a href="', ftr$linkedin, '" target="_blank" rel="noopener">LinkedIn</a>'),
  paste0('        <a href="', ftr$portfolio_url, '" target="_blank" rel="noopener" ', i18n(ftr$portfolio_en, ftr$portfolio_zh), ">", ftr$portfolio_en, "</a>"),
  "      </div>",
  "    </div>",
  "  </footer>",
  "",
  "  <script>",
  '    var currentLang = localStorage.getItem("wy_lang") || "en";',
  "    function applyLang(lang) {",
  "      currentLang = lang;",
  '      localStorage.setItem("wy_lang", lang);',
  '      document.documentElement.lang = lang === "zh" ? "zh-TW" : "en";',
  '      document.querySelectorAll("[data-i18n]").forEach(function(el) {',
  '        var text = el.getAttribute("data-" + lang);',
  "        if (text) el.textContent = text;",
  "      });",
  '      var btn = document.getElementById("langToggle");',
  '      btn.textContent = lang === "zh" ? "EN" : "\u7e41\u4e2d";',
  '      btn.setAttribute("aria-label", lang === "zh" ? "Switch to English" : "\u5207\u63db\u70ba\u7e41\u9ad4\u4e2d\u6587");',
  "    }",
  '    document.getElementById("langToggle").addEventListener("click", function() {',
  '      applyLang(currentLang === "en" ? "zh" : "en");',
  "    });",
  "    applyLang(currentLang);",
  "  </script>",
  "",
  "</body>",
  "</html>"
)

writeLines(lines, "index.html", useBytes = TRUE)
message("\u2713 index.html \u5df2\u7522\u751f")
