#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Squib用CSVを、teppen/teppen-cards.html を直接解析して生成する(teppenにはHTML以外の
データソースが無いため)。BOMなしUTF-8で出力する。
"""
import csv
from collections import OrderedDict
from pathlib import Path

from bs4 import BeautifulSoup

SRC = Path(__file__).resolve().parents[2] / "teppen" / "teppen-cards.html"
OUT = Path(__file__).resolve().parent / "data"
OUT.mkdir(parents=True, exist_ok=True)


def write_csv(filename, fieldnames, rows):
    path = OUT / filename
    with path.open("w", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)
    print(f"{filename}: {len(rows)} rows")


def main():
    soup = BeautifulSoup(SRC.read_text(encoding="utf-8"), "html.parser")
    articles = soup.select("article.card")

    members = OrderedDict()  # (number, role, flavor, effect) -> count
    turfs = []  # list of (value, turf_role, turf_flavor) - all unique, no dedup

    def portrait_key(art, prefix):
        el = art.select_one("span.portrait")
        for cls in el.get("class", []):
            # "turf-icon" 自体は汎用マーカークラスであって画像名ではないので除外する
            if cls.startswith(prefix) and cls != "turf-icon":
                return cls
        return ""

    for art in articles:
        role_el = art.select_one("p.role")
        if role_el is not None:
            number = art.select_one("span.corner-tl").get_text(strip=True)
            role = role_el.get_text(strip=True)
            flavor = art.select_one("p.flavor").get_text(strip=True)
            effect_el = art.select_one(".effect p")
            effect = effect_el.get_text(strip=True) if effect_el else ""
            image = portrait_key(art, "char-")
            key = (number, role, flavor, effect, image)
            members[key] = members.get(key, 0) + 1
        else:
            value = art.select_one("span.corner-tl").get_text(strip=True)
            turf_role = art.select_one("p.turf-role").get_text(strip=True)
            turf_flavor = art.select_one("p.turf-flavor").get_text(strip=True)
            image = portrait_key(art, "turf-")
            turfs.append((value, turf_role, turf_flavor, image))

    member_rows = [
        {"number": num, "role": role, "flavor": flavor, "effect": effect, "image": image, "Copies": count}
        for (num, role, flavor, effect, image), count in members.items()
    ]
    # 数字順に並べ替え(1→7)
    member_rows.sort(key=lambda r: int(r["number"]))
    write_csv("member.csv", ["number", "role", "flavor", "effect", "image", "Copies"], member_rows)

    turf_rows = [
        {"value": v, "turf_role": tr, "turf_flavor": tf, "image": image, "Copies": 1}
        for v, tr, tf, image in turfs
    ]
    # +1〜+10の順に並べ替え
    turf_rows.sort(key=lambda r: int(r["value"].lstrip("+")))
    write_csv("turf.csv", ["value", "turf_role", "turf_flavor", "image", "Copies"], turf_rows)

    total_members = sum(r["Copies"] for r in member_rows)
    total_turfs = sum(r["Copies"] for r in turf_rows)
    print(f"total: {total_members} member cards, {total_turfs} turf cards")


if __name__ == "__main__":
    main()
