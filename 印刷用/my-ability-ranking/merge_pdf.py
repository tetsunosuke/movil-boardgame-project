#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""deck_proto.rb / deck_print.rb が_output/に出力したPDFを、1つずつのPDFへ結合する。
使い方: python merge_pdf.py proto   または   python merge_pdf.py print
"""
import sys
import fitz
from pathlib import Path

HERE = Path(__file__).resolve().parent
OUT_DIR = HERE / "_output"

MODE = sys.argv[1] if len(sys.argv) > 1 else "print"

if MODE == "proto":
    # プロトタイプ版はスリーブ+厚紙で遊ぶ前提のため裏面画像は生成しない(厚紙が裏面を兼ねる)。
    # 白黒ページとカラーページ(番号カード おもて2種、色を使うのはここだけ)を別ファイルに分ける。
    # 白黒しかないページをカラープリンタで刷ってインクを無駄にしないため。
    # ability/tier、number_player/number_boardはそれぞれ1つの連続デッキとして
    # deck_proto.rbが既に9枚/ページで詰めて出力するため、マージは単一ファイルのコピーに等しい。
    BW_ORDER = ["bw_proto_all.pdf"]
    COLOR_ORDER = ["color_proto_all.pdf"]

    def merge(order, out_path):
        merged = fitz.open()
        total = 0
        for name in order:
            path = OUT_DIR / name
            with fitz.open(path) as part:
                merged.insert_pdf(part)
                total += part.page_count
            print(f"{name}: {fitz.open(path).page_count} pages merged")
        merged.save(out_path)
        merged.close()
        print(f"wrote {out_path} ({total} pages total)\n")

    merge(BW_ORDER, HERE / "私の能力ランキング_プロトタイプ用_白黒.pdf")
    merge(COLOR_ORDER, HERE / "私の能力ランキング_プロトタイプ用_カラー.pdf")
    raise SystemExit(0)
elif MODE == "print":
    ORDER = [
        "01_ability_pair.pdf",
        "02_tier_pair.pdf",
        "03_number_player_pair.pdf",
        "04_number_board_pair.pdf",
    ]
    FINAL = HERE / "私の能力ランキング_入稿用.pdf"
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
