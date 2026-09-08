#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""deck_proto.rb / deck_print.rb が_output/に出力したPDFを、1つずつのPDFへ結合する。
使い方: python merge_pdf.py proto   または   python merge_pdf.py print
プロトタイプ版はスリーブ+厚紙で遊ぶ前提のため裏面画像は生成しない(厚紙が裏面を兼ねる)。
おもてのみになった結果、プロトタイプ版は写真素材を使うページ(カラー)のみになる。
"""
import sys
import fitz
from pathlib import Path

HERE = Path(__file__).resolve().parent
OUT_DIR = HERE / "_output"

MODE = sys.argv[1] if len(sys.argv) > 1 else "print"

if MODE == "proto":
    # member/turfを1つの連続デッキとしてdeck_proto.rbが既に9枚/ページで詰めて出力するため、
    # マージは単一ファイルのコピーに等しい。
    ORDER = ["teppen_proto_all.pdf"]
    FINAL = HERE / "テッペン_プロトタイプ用.pdf"
elif MODE == "print":
    ORDER = ["01_member_pair.pdf", "02_turf_pair.pdf"]
    FINAL = HERE / "テッペン_入稿用.pdf"
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
