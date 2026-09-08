#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Squib用CSVを、my-ability-ranking/src/abilities.py のマスタデータから直接生成する。
実データを手打ちせず、唯一の情報源(abilities.py)からそのまま作る。
BOMなしUTF-8で出力する(SquibのRuby CSVパーサーはBOM付きだと先頭列のヘッダー名が壊れるため)。
"""
import csv
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2] / "my-ability-ranking" / "src"))
from abilities import KISO, SONOTA, WAKU, TIERS

OUT = Path(__file__).resolve().parent / "data"
OUT.mkdir(parents=True, exist_ok=True)


def write_csv(filename, fieldnames, rows):
    path = OUT / filename
    with path.open("w", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)
    print(f"{filename}: {len(rows)} rows")


def export_ability_front():
    rows = []
    for i, (name, definition) in enumerate(KISO):
        rows.append({
            "band_type": "k", "band_label": "社会人基礎力",
            "code": f"No.{i + 1:02d}", "name": name, "definition": definition, "Copies": 1,
        })
    for i, (name, definition) in enumerate(SONOTA):
        rows.append({
            "band_type": "s", "band_label": "その他の能力",
            "code": f"No.{i + 13:02d}", "name": name, "definition": definition, "Copies": 1,
        })
    write_csv("ability_front.csv", ["band_type", "band_label", "code", "name", "definition", "Copies"], rows)


def export_ability_back():
    rows = [
        {"band_type": "k", "label": "社会人基礎力", "sub": "12枚の山", "Copies": len(KISO)},
        {"band_type": "s", "label": "その他の能力", "sub": "18枚の山", "Copies": len(SONOTA)},
    ]
    write_csv("ability_back.csv", ["band_type", "label", "sub", "Copies"], rows)


def export_tier():
    # 各Tierごとに個体番号1〜3を振る(元のcards.pyのCONF = [(l,n,lv,cap) ... for n in (1,2,3)]と同じ)。
    # 個体ごとに表示が変わる(num違い)ため、Copiesでまとめず12行すべてを別カードとして書き出す。
    rows = []
    for letter, level, cap in TIERS:
        for num in (1, 2, 3):
            rows.append({
                "letter": letter, "num": num, "level": level,
                "bar1": int(level >= 1), "bar2": int(level >= 2),
                "bar3": int(level >= 3), "bar4": int(level >= 4),
                "cap": cap, "Copies": 1,
            })
    write_csv("tier.csv", ["letter", "num", "level", "bar1", "bar2", "bar3", "bar4", "cap", "Copies"], rows)


def export_number_player():
    rows = []
    for n, cname, bg, fg in WAKU:
        rows.append({
            "n": n, "color_name": cname, "hint": f"場では{cname}のカード",
            "bg_hex": bg, "fg_hex": fg, "Copies": 6,
        })
    write_csv("number_player.csv", ["n", "color_name", "hint", "bg_hex", "fg_hex", "Copies"], rows)


def export_number_board():
    rows = []
    for n, cname, bg, fg in WAKU:
        rows.append({
            "n": n, "color_name": cname, "bg_hex": bg, "fg_hex": fg,
            "is_white": int(bg.upper() == "#FFFFFF"), "Copies": 1,
        })
    write_csv("number_board.csv", ["n", "color_name", "bg_hex", "fg_hex", "is_white", "Copies"], rows)


if __name__ == "__main__":
    export_ability_front()
    export_ability_back()
    export_tier()
    export_number_player()
    export_number_board()
