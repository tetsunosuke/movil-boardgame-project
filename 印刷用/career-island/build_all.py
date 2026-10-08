#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""キャリア・アイランドの印刷物を、data/*.csv からまとめて再生成する(1コマンド版)。

使い方(このフォルダ、または別の場所から):
    python build_all.py            # CSV点検 → 入稿用/プロトタイプ用PDF → HTMLプレビュー → カードPDF
    python build_all.py --sync     # 上記に加えて flyers/(公開用フォルダ)へコピー(commit/pushはしない)

CSVをExcelで編集した場合の事故を防ぐため、最初に次を自動で行う:
  - UTF-8のBOM(Excelの「CSV UTF-8」保存で付く)を除去する
  - Shift-JIS(Excelの「CSV(コンマ区切り)」保存)で保存されていたら、UTF-8に変換する
  - 必須の列(icon,badge,name,...)が揃っているか点検する(揃っていなければ止める)
最後に、カードから文字があふれていないかのレポート(layout slack)を表示する。
「!!! OVERLAP」と出たカードは文字が重なっているので、CSVの文言を短くすること。

注意: Web版(src/data/tileContent.ts・decks.ts)はこのCSVを自動では読まない。Web版にも反映したい
場合は別途手で写す必要がある。
"""
import csv
import io
import os
import subprocess
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
PROJECT = HERE.parents[1]
GAME = PROJECT / "career-island"
DATA = HERE / "data"

GENERIC_COLUMNS = ["icon", "badge", "name", "prompt", "effect_label", "effect_value", "bonus", "setup", "Copies"]
REQUIRED = {
    "trouble.csv": GENERIC_COLUMNS, "life.csv": GENERIC_COLUMNS, "role.csv": GENERIC_COLUMNS,
    "age.csv": GENERIC_COLUMNS, "goal.csv": GENERIC_COLUMNS, "token.csv": GENERIC_COLUMNS,
    "labor.csv": GENERIC_COLUMNS, "learning.csv": GENERIC_COLUMNS, "leisure.csv": GENERIC_COLUMNS,
    "love.csv": GENERIC_COLUMNS,
    "dilemma.csv": ["icon", "badge", "name", "opt_a_label", "opt_a_text", "opt_b_label", "opt_b_text", "Copies"],
    "coord_draw.csv": ["label"],
    "love_luck.csv": ["label", "Copies"],
}


def normalize_and_check():
    problems = []
    for name, cols in REQUIRED.items():
        p = DATA / name
        if not p.exists():
            problems.append(f"{name}: ファイルが見つかりません")
            continue
        raw = p.read_bytes()
        text = None
        if raw.startswith(b"\xef\xbb\xbf"):
            raw = raw[3:]
            print(f"  {name}: BOMを除去しました")
            text = raw.decode("utf-8")
            p.write_bytes(raw)
        else:
            try:
                text = raw.decode("utf-8")
            except UnicodeDecodeError:
                text = raw.decode("cp932")
                p.write_bytes(text.encode("utf-8"))
                print(f"  {name}: Shift-JISで保存されていたため、UTF-8に変換しました")
        rows = list(csv.DictReader(io.StringIO(text, newline="")))
        header = rows[0].keys() if rows else csv.reader(io.StringIO(text)).__next__()
        missing = [c for c in cols if c not in header]
        if missing:
            problems.append(f"{name}: 列が足りません {missing}(1行目の見出しを変えていませんか?)")
        broken = [i for i, r in enumerate(rows, start=2) if None in r or None in r.values()]
        if broken:
            problems.append(
                f"{name}: 列の数が合わないデータ行があります(データ{len(broken)}件)。セルの中で改行したのに、そのセルを"
                "「\"」で囲んでいない可能性が高いです(メモ帳等で編集するとき、改行を含むセルは「\"…\"」で囲む必要があります。"
                "Excelなら Alt+Enter で入れた改行は自動で囲まれます)")
            continue
        for i, r in enumerate(rows, start=2):
            if "Copies" in cols and not str(r.get("Copies", "")).strip().isdigit():
                problems.append(f"{name}: {i}行目の Copies が数字ではありません({r.get('Copies')!r})")
    if problems:
        print("\nCSVに問題があります。直してからもう一度実行してください:")
        for m in problems:
            print("  -", m)
        sys.exit(1)


def run(cmd, cwd, label, capture=False):
    env = dict(os.environ, PYTHONUTF8="1")
    ruby_bin = Path("C:/Ruby34-x64/bin")
    if ruby_bin.exists():
        env["PATH"] = str(ruby_bin) + os.pathsep + env["PATH"]
    print(f"\n== {label}")
    res = subprocess.run(cmd, cwd=cwd, env=env, text=True, encoding="utf-8", errors="replace",
                         capture_output=True)
    out = (res.stdout or "") + (res.stderr or "")
    if res.returncode != 0:
        print(out)
        print(f"失敗しました: {label}")
        if "Permission denied" in out or "PermissionError" in out:
            print("→ 出力先のPDFをAcrobatなどで開いたままにしていませんか? 閉じてから再実行してください。")
        sys.exit(res.returncode)
    return out


def main():
    sync = "--sync" in sys.argv
    print("== CSVの点検")
    normalize_and_check()
    reports = []
    for deck in ("deck_print.rb", "deck_proto.rb"):
        out = run(["ruby", deck], HERE, f"Squib: {deck}")
        reports += [l for l in out.splitlines() if "min slack" in l or "OVERLAP" in l]
    py = sys.executable
    run([py, "merge_pdf.py", "print"], HERE, "PDF結合(入稿用)")
    run([py, "merge_pdf.py", "proto"], HERE, "PDF結合(プロトタイプ用)")
    run([py, "gen_html.py"], HERE, "HTMLプレビュー生成")
    run(["node", "scripts/gen_cards_pdf.mjs"], GAME, "HTMLプレビュー→PDF")
    if sync:
        run(["node", "scripts/sync_flyers.mjs"], PROJECT, "flyers/ へ同期")

    print("\n== レイアウト余白レポート(mm。小さいほどタイト、負なら文字が重なっている)")
    seen = set()
    for l in reports:
        if l not in seen:
            seen.add(l)
            print(l)
    if any("OVERLAP" in l for l in reports):
        print("\n!!! 文字が重なっているカードがあります。上の OVERLAP の行を確認し、CSVの文言を短くしてください。")
    print("\n出力:")
    for f in ("キャリア・アイランド_入稿用.pdf", "キャリア・アイランド_プロトタイプ用.pdf"):
        print("  ", HERE / f)
    print("  ", GAME / "career-island-cards.html")
    print("  ", GAME / "career-island-cards.pdf")
    if not sync:
        print("\n(flyers/ への公開用コピーは --sync を付けて実行すると行われます)")


if __name__ == "__main__":
    main()
