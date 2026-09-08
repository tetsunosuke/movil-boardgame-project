#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""deck_proto.rb / deck_print.rb が_output/に出力したPDFを、1つずつのPDFへ結合する。
使い方: python merge_pdf.py proto   または   python merge_pdf.py print
career-islandは全カード完全モノクロ設計のため、プロトタイプ版もカラー分離は不要(1ファイルのみ)。
プロトタイプ版はスリーブ+厚紙で遊ぶ前提のため、裏面画像は一切生成しない(厚紙が裏面を兼ねる)。
座標カード(抽選用25枚)はもともと裏面なし。盤面目印用ストリップ2枚は不要とのことで
プロトタイプ版・入稿用ともに含めない。
"""
import sys
import fitz
from pathlib import Path

HERE = Path(__file__).resolve().parent
OUT_DIR = HERE / "_output"

MODE = sys.argv[1] if len(sys.argv) > 1 else "print"

GENERIC = ["trouble", "life", "role", "age", "goal", "token", "labor", "learning", "leisure", "love"]

if MODE == "proto":
    # 全型を1つの連続デッキとしてdeck_proto.rbが既に9枚/ページで詰めて出力するため、
    # マージは単一ファイルのコピーに等しい(型ごとに分かれていた頃の端数ページはもう出ない)。
    ORDER = ["career_island_proto_all.pdf"]
    FINAL = HERE / "キャリア・アイランド_プロトタイプ用.pdf"
elif MODE == "print":
    ORDER = [f"{i:02d}_{ctype}_pair.pdf" for i, ctype in enumerate(GENERIC, start=1)]
    ORDER += ["11_dilemma_pair.pdf"]
    ORDER += ["12_coord_draw.pdf"]
    ORDER += ["13_love_luck.pdf"]
    FINAL = HERE / "キャリア・アイランド_入稿用.pdf"
else:
    raise SystemExit(f"unknown mode: {MODE} (use 'proto' or 'print')")

merged = fitz.open()
total_pages = 0
for name in ORDER:
    path = OUT_DIR / name
    with fitz.open(path) as part:
        merged.insert_pdf(part)
        total_pages += part.page_count
    print(f"{name}: {fitz.open(path).page_count} pages merged")

merged.save(FINAL)
merged.close()
print(f"\nwrote {FINAL} ({total_pages} pages total)")
