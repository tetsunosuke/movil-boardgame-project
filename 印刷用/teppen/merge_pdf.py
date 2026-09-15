#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""deck_proto.rb / deck_print.rb が_output/に出力したPDFを、1つずつのPDFへ結合する。
使い方: python merge_pdf.py proto   または   python merge_pdf.py print
プロトタイプ版はプレイヤーごとに手札を配って手元に隠し持つ運用のため裏面が必要
(2026-09-14〜)。2026-09-15、表裏ペアを1枚の紙に収める山折り方式(1枚あたり最大4組が
面積上の上限)から、表だけ・裏だけをそれぞれ9枚/A4で詰めた別々のシートに変更し、
印刷後に同じ種類同士(手下は手下、ナワバリはナワバリ)を貼り合わせる方式にした
(裏は共通デザインなので特定の表との対応は不要)。そのため表用・裏用の2つの最終PDFを出力する。
"""
import sys
import fitz
from pathlib import Path

HERE = Path(__file__).resolve().parent
OUT_DIR = HERE / "_output"

MODE = sys.argv[1] if len(sys.argv) > 1 else "print"


def merge(order, final):
    merged = fitz.open()
    total_pages = 0
    for name in order:
        path = OUT_DIR / name
        with fitz.open(path) as part:
            merged.insert_pdf(part)
            total_pages += part.page_count
        print(f"{name}: {fitz.open(path).page_count} pages merged")
    merged.save(final)
    merged.close()
    print(f"wrote {final} ({total_pages} pages total)\n")


if MODE == "proto":
    merge(["teppen_proto_front.pdf"], HERE / "テッペン_プロトタイプ用_表.pdf")
    merge(["teppen_proto_back.pdf"], HERE / "テッペン_プロトタイプ用_裏.pdf")
elif MODE == "print":
    merge(["01_member_pair.pdf", "02_turf_pair.pdf"], HERE / "テッペン_入稿用.pdf")
else:
    raise SystemExit(f"unknown mode: {MODE} (use 'proto' or 'print')")
