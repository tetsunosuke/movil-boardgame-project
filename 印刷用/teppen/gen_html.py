#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""data/member.csv・data/turf.csv (編集の原本) から teppen-cards.html
(ブラウザ確認用プレビュー) を生成する。
2026-09-15、career-island方式に合わせてteppenも「HTMLが原本」から「CSVが原本」に反転した。
今後カード内容を変更する場合は data/member.csv・data/turf.csv を直接編集し、このスクリプトで
HTMLプレビューを再生成すること(HTMLファイル自体は手編集しないこと。次回生成時に上書きされる)。
印刷用PDF(deck_print.rb/deck_proto.rb)はCSVを直接読むため、このスクリプトの実行は必須ではない
(あくまでブラウザ上で内容を見返すためのプレビュー生成)。

キャラクター画像(char-*)・ナワバリ画像(turf-*)のファイル対応はCSVの image 列にクラス名のみ
持たせ、クラス→実ファイルパスの対応はこのスクリプト側に固定で持つ(art directionであり、
カードの「内容」ではないため)。実際の画像を差し替えたい場合は同名ファイルを差し替えるか、
このスクリプトの IMAGE_MAP を編集すること。
"""
import csv
import html
from pathlib import Path

DATA_DIR = Path(__file__).resolve().parent / "data"
OUT = Path(__file__).resolve().parents[2] / "teppen" / "teppen-cards.html"

IMAGE_MAP = {
    "char-banchou": "キャラクター/7.jpg",
    "char-wakate": "キャラクター/2.jpg",
    "char-jouhouya": "キャラクター/1.jpg",
    "char-kanbukouho": "キャラクター/4.jpg",
    "char-kanbu": "キャラクター/5.jpg",
    "char-wakagashira": "キャラクター/6.jpg",
    "char-banchounoimouto": "キャラクター/3.jpg",
    "turf-toilet": "ナワバリ/1_公衆便所裏.jpg",
    "turf-vending": "ナワバリ/2_自販機の裏.jpg",
    "turf-bicycle": "ナワバリ/3_路地裏の駐輪場.jpg",
    "turf-candy": "ナワバリ/4_駄菓子屋横丁.jpg",
    "turf-arcade-game": "ナワバリ/5_ゲーセン.jpg",
    "turf-shotengai": "ナワバリ/6_商店街アーケード.jpg",
    "turf-riverbank": "ナワバリ/7_河川敷.jpg",
    "turf-rotary": "ナワバリ/8_駅前ロータリー.jpg",
    "turf-rooftop": "ナワバリ/9_廃ビルの屋上.jpg",
    "turf-neon": "ナワバリ/10_ネオン繁華街.jpg",
}


def esc(s):
    return html.escape(s or "", quote=True)


def read_csv(name):
    path = DATA_DIR / name
    with path.open(encoding="utf-8", newline="") as f:
        return list(csv.DictReader(f))


def render_member_card(row):
    number = row["number"]
    effect_html = ""
    if row["effect"]:
        effect_html = (
            '<div class="effect"><span class="effect-tag stencil">特殊効果</span>'
            f'<p>{esc(row["effect"])}</p></div>'
        )
    card = (
        f'<article class="card"><span class="corner corner-tl">{esc(number)}</span>'
        f'<div class="center"><span class="portrait {esc(row["image"])}"></span>'
        f'<p class="role">{esc(row["role"])}</p>'
        f'<p class="flavor">{esc(row["flavor"])}</p>'
        f'{effect_html}</div>'
        f'<span class="corner corner-br">{esc(number)}</span></article>'
    )
    return card * max(int(row["Copies"]), 1)


def render_turf_card(row):
    value = row["value"]
    card = (
        '<article class="card">'
        f'<span class="corner corner-tl corner-plus">{esc(value)}</span>'
        '<div class="center">'
        f'<span class="portrait turf-icon {esc(row["image"])}"></span>'
        f'<p class="turf-role">{esc(row["turf_role"])}</p>'
        f'<p class="turf-flavor">{esc(row["turf_flavor"])}</p>'
        '</div>'
        f'<span class="corner corner-br corner-plus">{esc(value)}</span>'
        '</article>'
    )
    return card * max(int(row["Copies"]), 1)


def image_css():
    return "\n".join(f"  .{cls}{{ background-image:url('{path}'); }}" for cls, path in IMAGE_MAP.items())


HEAD = """<!-- このHTMLは data/member.csv・data/turf.csv から 印刷用/teppen/gen_html.py に
     よって自動生成されるプレビューです。内容を変更する場合はこのファイルではなく
     data/*.csv を編集し、python gen_html.py を再実行してください。直接編集しても
     次回上書きされます。 -->
<title>テッペン カード原案</title>
<meta name="description" content="不良チーム抗争ゲーム『テッペン』カードのみ・ベータ版（情報優先デザイン）・6人プレイ分">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Rampart+One&family=RocknRoll+One&family=Zen+Kaku+Gothic+New:wght@400;500;700&family=Big+Shoulders+Stencil:wght@600;800&display=swap">

<style>
  :root{
    --page-bg: #e6e6e6;
    --page-ink: #141414;
    --page-mute: #737373;
    --card-bg: #fafafa;
    --ink: #141414;
    --hair: rgba(20,20,20,0.16);
  }
  @media (prefers-color-scheme: dark){
    :root:not([data-theme="light"]){
      --page-bg: #161616;
      --page-ink: #ececec;
      --page-mute: #9c9c9c;
      --hair: rgba(236,236,236,0.14);
    }
  }
  :root[data-theme="dark"]{
    --page-bg: #161616;
    --page-ink: #ececec;
    --page-mute: #9c9c9c;
    --hair: rgba(236,236,236,0.14);
  }

  *{box-sizing:border-box;}
  body{
    margin:0;
    background: var(--page-bg);
    color:var(--page-ink);
    font-family:"Zen Kaku Gothic New", "Hiragino Sans", sans-serif;
    padding: 14px;
  }
  .stencil{ font-family:"Big Shoulders Stencil", sans-serif; text-transform:uppercase; letter-spacing:.14em; }

  .rack{
    display:grid;
    grid-template-columns: repeat(auto-fill, 63mm);
    gap: 0;
    justify-content:start;
    border-top: 0.9mm solid var(--ink);
    border-left: 0.9mm solid var(--ink);
    width:max-content; max-width:100%;
    margin: 0 auto;
  }

  .card{
    width: 63mm;
    height: 88mm;
    background: var(--card-bg);
    border-right: 0.9mm solid var(--ink);
    border-bottom: 0.9mm solid var(--ink);
    padding: 3mm 3.4mm 3mm;
    display:flex; flex-direction:column; justify-content:space-between;
    position:relative;
  }

  .corner{
    font-family:"Rampart One", sans-serif;
    font-size: 1.6rem; line-height:1; color: var(--ink);
  }
  .corner-tl{ align-self:flex-start; }
  .corner-br{ align-self:flex-end; transform:rotate(180deg); }

  .corner-plus{ font-size:1.3rem; border:1.6px solid var(--ink); border-radius:5px; padding:2px 9px 4px; }
  .corner-zero{
    font-size:1.2rem; border:1.6px solid var(--ink); border-radius:50%;
    width:1.85em; height:1.85em; display:inline-flex; align-items:center; justify-content:center; padding:0;
  }

  .center{
    flex:1; display:flex; flex-direction:column; align-items:center; justify-content:center;
    text-align:center; gap:5px; padding:2px 1mm; min-height:0;
  }
  .role{
    font-family:"RocknRoll One", sans-serif;
    font-size: 1.55rem; line-height:1.2; margin:0;
  }
  .flavor{
    font-size:.62rem; color:var(--page-mute); line-height:1.35; margin:0; text-wrap:balance;
  }
  .effect{
    border: 1.3px solid var(--ink); border-radius:5px;
    padding: 4px 7px 6px; margin-top:2px; text-align:left;
  }
  .effect-tag{
    display:block; font-size:.48rem; margin-bottom:2px; color:var(--page-mute);
  }
  .effect p{ margin:0; font-size:.58rem; line-height:1.4; }

  .art{ flex:1; display:flex; align-items:center; justify-content:center; margin:2px 0; min-height:0; }
  .art svg{ width:78%; height:78%; overflow:visible; }

  .turf-role{ font-family:"RocknRoll One", sans-serif; font-size:.98rem; margin:2px 0 0; text-align:center; }
  .turf-flavor{ font-size:.55rem; color:var(--page-mute); line-height:1.3; margin:1px 0 0; text-align:center; text-wrap:balance; }

  /* 入稿用: 塗り足し3mm(A4 210×297mm + 3mm×2 = 216×303mm)。トンボはposition:fixedで
     全ページ共通の四隅に固定表示(Chromiumの印刷/PDF出力ではfixed要素が各生成ページに
     繰り返し描画されることを確認済み)。色モードはRGBのまま(印刷会社側でCMYK変換する前提)。 */
  @media print{
    @page{ size: 216mm 303mm; margin: 0; }
    body{ background:#fff !important; color:#000; position:absolute; top:3mm; left:3mm; width:210mm; padding:8mm; }
    .rack{ grid-template-columns: repeat(3, 63mm); }
    .card{ break-inside: avoid; }
    .crop{ display:block; position:fixed; background:#000; }
  }
  .crop{ display:none; }
  .crop.tl-h{ top:3mm; left:0; width:3mm; height:0.2mm; }
  .crop.tl-v{ top:0; left:3mm; width:0.2mm; height:3mm; }
  .crop.tr-h{ top:3mm; right:0; width:3mm; height:0.2mm; }
  .crop.tr-v{ top:0; right:3mm; width:0.2mm; height:3mm; }
  .crop.bl-h{ bottom:3mm; left:0; width:3mm; height:0.2mm; }
  .crop.bl-v{ bottom:0; left:3mm; width:0.2mm; height:3mm; }
  .crop.br-h{ bottom:3mm; right:0; width:3mm; height:0.2mm; }
  .crop.br-v{ bottom:0; right:3mm; width:0.2mm; height:3mm; }
  .portrait{ width:60%; aspect-ratio:1/1; margin:0 auto 1mm; border-radius:50%; background-size:cover; background-position:center; }
{IMAGE_CSS}
</style>

<svg width="0" height="0" style="position:absolute">
  <defs>
    <polygon id="star" points="0,-10 2.245,-3.09 9.511,-3.09 3.633,1.18 5.878,8.09 0,3.82 -5.878,8.09 -3.633,1.18 -9.511,-3.09 -2.245,-3.09"/>
    <pattern id="dots" width="6" height="6" patternUnits="userSpaceOnUse">
      <circle cx="1.5" cy="1.5" r="1.15" fill="var(--ink)"/>
    </pattern>
    <pattern id="dotsFine" width="4" height="4" patternUnits="userSpaceOnUse">
      <circle cx="1" cy="1" r=".7" fill="var(--ink)"/>
    </pattern>
    <pattern id="hazard" width="14" height="14" patternUnits="userSpaceOnUse" patternTransform="rotate(45)">
      <rect width="14" height="14" fill="var(--card-bg)"/>
      <rect width="7" height="14" fill="var(--ink)"/>
    </pattern>
  </defs>
</svg>

<span class="crop tl-h"></span><span class="crop tl-v"></span>
<span class="crop tr-h"></span><span class="crop tr-v"></span>
<span class="crop bl-h"></span><span class="crop bl-v"></span>
<span class="crop br-h"></span><span class="crop br-v"></span>

<div class="rack">
"""

TAIL = """
</div>
"""


def main():
    member_rows = read_csv("member.csv")
    turf_rows = read_csv("turf.csv")

    parts = [HEAD.replace("{IMAGE_CSS}", image_css())]
    for row in member_rows:
        parts.append(render_member_card(row))
    for row in turf_rows:
        parts.append(render_turf_card(row))
    parts.append(TAIL)

    OUT.write_text("".join(parts), encoding="utf-8")
    total_members = sum(int(r["Copies"]) for r in member_rows)
    total_turfs = sum(int(r["Copies"]) for r in turf_rows)
    print(f"wrote {OUT} ({total_members} member cards, {total_turfs} turf cards)")


if __name__ == "__main__":
    main()
