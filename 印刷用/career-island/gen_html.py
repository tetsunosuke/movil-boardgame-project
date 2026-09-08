#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""data/*.csv (編集の原本) から career-island-cards.html (ブラウザ確認用プレビュー) を生成する。
以前はHTMLが原本でCSVはそこから抽出する生成物だったが、CSVの方が編集しやすいため
関係を逆転させた。今後カード内容を変更する場合は data/*.csv を直接編集し、このスクリプトで
HTMLプレビューを再生成する(HTMLファイル自体は手編集しないこと)。
印刷用PDF(deck_print.rb/deck_proto.rb)はCSVを直接読むため、このスクリプトの実行は必須ではない
(あくまでブラウザ上で内容を見返すためのプレビュー生成)。
"""
import csv
import html
from pathlib import Path

DATA_DIR = Path(__file__).resolve().parent / "data"
OUT = Path(__file__).resolve().parents[2] / "career-island" / "career-island-cards.html"

# [type, badge表示上の見出し(日本語ラベル), effect-valueにlongクラスを付けるか]
GENERIC_SECTIONS = [
    ("trouble", "▲ トラブルカード", True),
    ("life", "◆ ライフイベントカード", True),
    ("role", "■ 役職カード（3種×2枚／キャラメイクで1人1枚選ぶ・若年期は選択不可）", True),
    ("age", "● 年代カード", True),
    ("goal", "◎ キャリア目標カード", True),
    ("token", "◆ トークンカード（※各Leisure/Loveマスカードの下に1枚ずつ伏せて置く）", True),
    ("labor", "■ Labor（仕事）マスカード", False),
    ("learning", "●● Learning（学習）マスカード", False),
    ("leisure", "- - Leisure（余暇）マスカード", False),
    ("love", "・・・ Love（関係）マスカード", False),
]


def esc(s):
    return html.escape(s or "", quote=True)


def br(s):
    return esc(s).replace("\n", "<br>")


def read_csv(name):
    path = DATA_DIR / name
    with path.open(encoding="utf-8", newline="") as f:
        return list(csv.DictReader(f))


def render_generic_card(ctype, row, long_cls):
    icon = row["icon"]
    icon_html = f'<span class="card-icon">{esc(icon)}</span>' if icon else ""
    prompt_html = f'<div class="card-prompt">{br(row["prompt"])}</div>' if row["prompt"] else ""
    bonus_html = f'<div class="card-bonus">{br(row["bonus"])}</div>' if row["bonus"] else ""
    setup_html = f'<div class="card-setup">{br(row["setup"])}</div>' if row["setup"] else ""
    value_cls = "effect-value long" if long_cls else "effect-value"
    n = max(int(row["Copies"]), 1)
    card = (
        f'<div class="card {ctype}">{icon_html}'
        f'<span class="card-badge">{esc(row["badge"])}</span>'
        f'<div class="card-name">{br(row["name"])}</div>'
        f'{prompt_html}'
        f'<div class="card-effect"><span class="effect-label">{esc(row["effect_label"])}</span>'
        f'<span class="{value_cls}">{br(row["effect_value"])}</span></div>'
        f'{bonus_html}{setup_html}</div>'
    )
    return card * n


def render_dilemma_card(row):
    n = max(int(row["Copies"]), 1)
    card = (
        f'<div class="card dilemma"><span class="card-icon">{esc(row["icon"])}</span>'
        f'<span class="card-badge">{esc(row["badge"])}</span>'
        f'<div class="card-name">{br(row["name"])}</div>'
        f'<div class="dilemma-opt"><b>{esc(row["opt_a_label"])}</b>{br(row["opt_a_text"])}</div>'
        f'<div class="dilemma-opt"><b>{esc(row["opt_b_label"])}</b>{br(row["opt_b_text"])}</div>'
        f'</div>'
    )
    return card * n


def render_coord_section():
    rows = read_csv("coord_draw.csv")
    badges = "".join(f'<span class="coord-badge">{esc(r["label"])}</span>' for r in rows)
    return (
        '<div class="sheet-title">座標カード（抽選用、A-1〜E-5の25枚・裏面なし）</div>'
        f'<div class="coord-list">{badges}</div>'
    )


def render_love_luck_section():
    rows = read_csv("love_luck.csv")
    total = sum(int(r["Copies"]) for r in rows)
    badges = "".join(
        f'<span class="coord-badge">{esc(r["label"])}</span>' * int(r["Copies"]) for r in rows
    )
    return (
        f'<div class="sheet-title">絆抽選カード（Loveマス経験後に1枚引く、全{total}枚・裏面なし）</div>'
        f'<div class="coord-list">{badges}</div>'
    )


HEAD = """<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="UTF-8">
<title>キャリア・アイランド カード内容プレビュー</title>
<!-- このHTMLは data/*.csv から gen_html.py によって自動生成されるプレビューです。
     内容を変更する場合はこのファイルではなく data/*.csv を編集し、
     python gen_html.py を再実行してください。直接編集しても次回上書きされます。 -->
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Zen+Kaku+Gothic+New:wght@500;700;900&family=Plus+Jakarta+Sans:wght@400;600;700&display=swap" rel="stylesheet">
<style>
  :root {
    --text:   #111111;
    --muted:  #555555;
    --font-main: 'Zen Kaku Gothic New', 'Plus Jakarta Sans', sans-serif;
  }
  * { box-sizing: border-box; margin:0; padding:0; }
  body { font-family: var(--font-main); color: var(--text); background: #f2f2f2; padding: 8mm; }

  .sheet-title { font-size: 14px; font-weight:800; color: var(--muted); margin: 6mm 0 3mm; }

  .grid {
    display: flex;
    flex-wrap: wrap;
    gap: 3mm;
    margin-bottom: 4mm;
  }

  .card {
    width: 63mm;
    min-height: 88mm;
    border-radius: 4mm;
    padding: 3.5mm 3.2mm;
    display: flex;
    flex-direction: column;
    position: relative;
    background: #fff;
    border: 2px solid #000;
  }
  .card.life    { border-style: double; border-width: 4px; }
  .card.dilemma { border-style: dashed; }
  .card.learning{ border-style: double; border-width: 4px; }
  .card.leisure { border-style: dashed; }
  .card.love    { border-style: dotted; border-width: 3px; }
  .card.role    { border-style: solid;  border-width: 3px; }
  .card.age     { border-style: dashed; border-width: 3px; }
  .card.goal    { border-style: double; border-width: 5px; }
  .card.token   { border-style: solid; border-width: 2px; align-items: center; text-align: center; }
  .card.token .card-name { margin-top: 4mm; font-size: 17px; }
  .card.token .card-effect { margin-top: 3mm; }
  .card.token .card-setup { margin-top: auto; font-size: 7.5px; color: var(--muted); line-height: 1.4; border-top: 1px dashed #999; padding-top: 2mm; }

  .card-badge {
    font-size: 9px; font-weight: 800; color:#000;
    padding: 1.5px 7px; border: 1px solid #000; border-radius: 10px; display:inline-block; width: fit-content;
  }

  .card-icon { position:absolute; top:3.5mm; right:3.2mm; font-size:13px; }

  .card-name {
    font-size: 13.5px;
    font-weight: 900;
    line-height: 1.35;
    margin-top: 3mm;
  }

  .card-prompt {
    font-size: 8.5px;
    color: var(--muted);
    line-height: 1.4;
    margin-top: 2mm;
  }

  .card-effect {
    margin-top: auto;
    border: 1.5px solid #000;
    border-radius: 2mm;
    padding: 1.8mm 2mm;
    text-align: center;
  }
  .effect-label {
    display: block;
    font-size: 7px;
    font-weight: 800;
    letter-spacing: 1.5px;
    color: var(--muted);
    margin-bottom: 0.8mm;
  }
  .effect-value {
    display: block;
    font-size: 13px;
    font-weight: 900;
    line-height: 1.3;
  }
  .effect-value.long { font-size: 10px; line-height: 1.35; }

  .card-bonus {
    margin-top: 1.5mm;
    font-size: 7.3px;
    line-height: 1.4;
    color: var(--muted);
    text-align: center;
  }

  .dilemma-opt { font-size: 8.4px; line-height: 1.4; margin-top: 2mm; }
  .dilemma-opt b { display:block; font-size: 8.8px; margin-bottom: 1px; }

  .coord-list { display: flex; flex-wrap: wrap; gap: 2mm; margin-bottom: 4mm; }
  .coord-badge {
    display: inline-block; width: 14mm; text-align: center; padding: 2mm 0;
    border: 1px solid #000; border-radius: 2mm; font-weight: 900; font-size: 12px; background: #fff;
  }
</style>
</head>
<body>
"""

TAIL = """</body>
</html>
"""


def main():
    parts = [HEAD]
    for ctype, title, long_cls in GENERIC_SECTIONS:
        rows = read_csv(f"{ctype}.csv")
        total = sum(int(r["Copies"]) for r in rows)
        parts.append(f'<div class="sheet-title">{esc(title)}（全{total}枚）</div>')
        parts.append('<div class="grid">')
        parts.extend(render_generic_card(ctype, r, long_cls) for r in rows)
        parts.append('</div>')

        if ctype == "life":
            rows = read_csv("dilemma.csv")
            total = sum(int(r["Copies"]) for r in rows)
            parts.append(f'<div class="sheet-title">？ ジレンマカード（全{total}枚）</div>')
            parts.append('<div class="grid">')
            parts.extend(render_dilemma_card(r) for r in rows)
            parts.append('</div>')

        if ctype == "goal":
            parts.append(render_coord_section())
            parts.append(render_love_luck_section())

    parts.append(TAIL)
    OUT.write_text("".join(parts), encoding="utf-8")
    print(f"wrote {OUT}")


if __name__ == "__main__":
    main()
