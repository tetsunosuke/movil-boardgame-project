#!/usr/bin/env ruby
# encoding: utf-8
# 「テッペン」入稿用カード印刷データ(Squib版)。gr@phic「トレーディングカード小」想定。
# 表→裏が隣接する順(1表,1裏,2表,2裏,...)で並べる。
# require_relative は日本語(非ASCII)パスを含むWindows環境でスクリプト自身のパス解決に
# 失敗することがあるため、Dir.pwd基点の絶対パスで明示的にrequireする。
require File.expand_path(File.join(Dir.pwd, '..', '_lib', 'squib_common'))
include Squibcommon
include Squibcommon::Print

FONT = 'Yu Gothic'
FONT_STENCIL = 'Rockwell'  # 手下カードの威圧感を出すゴツいフォント(未インストール時はSansへ自動フォールバック)
IMG_DIR = 'images'
Squib.configure(img_dir: IMG_DIR)
PORTRAIT_SIZE = 28.0  # mm

# ── 1〜2. 手下カード おもて/うら (1〜7、Copies展開で60枚→120ページ) ──
data = Squib.csv file: 'data/member.csv', explode: 'Copies'
n = data['number'].size
has_effect = data['effect'].map { |e| !e.to_s.empty? }
fr = front_range(n)
br = back_range(n)

Squib::Deck.new(width: CARD_W, height: CARD_H, cards: n * 2) do
  background color: :white, range: :all

  # おもて
  text str: interleave(data['number'], nil), x: tx(USABLE_X), y: ty(2), width: '14mm', height: '10mm',
       font: "#{FONT_STENCIL} bold 26", align: :left, valign: :middle, range: fr
  png file: interleave(data['image'].map { |i| "#{i}.png" }, nil),
      x: tx((TRIM_W - PORTRAIT_SIZE) / 2), y: ty(13), width: "#{PORTRAIT_SIZE}mm", height: "#{PORTRAIT_SIZE}mm"
  text str: interleave(data['role'], nil), x: tx(USABLE_X), y: ty(43), width: "#{USABLE_W}mm", height: '9mm',
       font: "#{FONT} bold 16", align: :center, valign: :middle, range: fr
  text str: interleave(data['flavor'], nil), x: tx(USABLE_X), y: ty(52), width: "#{USABLE_W}mm", height: '7mm',
       font: "#{FONT} 7.5", align: :center, valign: :middle, color: '#737373', range: fr

  # 特殊効果ボックス(1,7のみ。効果が無いカードでは高さ0の空文字列を描くだけなので実害なし)
  rect x: tx(USABLE_X), y: ty(60), width: "#{USABLE_W}mm", height: '18mm',
       stroke_color: interleave(has_effect.map { |e| e ? :black : '#0000' }, nil),
       stroke_width: 1.3, range: fr
  text str: interleave(has_effect.map { |e| e ? '特殊効果' : '' }, nil),
       x: tx(USABLE_X + 2), y: ty(62), width: "#{USABLE_W - 4}mm", height: '4mm',
       font: "#{FONT} bold 6", color: '#737373', range: fr
  text str: interleave(data['effect'], nil), x: tx(USABLE_X + 2), y: ty(67), width: "#{USABLE_W - 4}mm", height: '10mm',
       font: "#{FONT} 6.8", range: fr

  # うら(手下カードは伏せて出すため、番号によらず完全に同一のデザインであることが重要)
  rect x: tx(3), y: ty(3), width: "#{TRIM_W - 6}mm", height: "#{TRIM_H - 6}mm",
       stroke_color: :black, stroke_width: 1.5, range: br
  text str: 'テッペン', x: tx(USABLE_X), y: ty(TRIM_H / 2 - 8), width: "#{USABLE_W}mm", height: '16mm',
       font: "#{FONT} bold 20", align: :center, valign: :middle, range: br
  text str: '手下', x: tx(USABLE_X), y: ty(TRIM_H / 2 + 8), width: "#{USABLE_W}mm", height: '8mm',
       font: "#{FONT} 9", align: :center, valign: :middle, color: '#737373', range: br

  save_pdf(**pdf_opts('01_member_pair'))
end
puts "01_member_pair: #{n} pairs (#{n * 2} pages)"

# ── 3〜4. ナワバリカード おもて/うら (10枚、Copiesなし→20ページ) ──
data = Squib.csv file: 'data/turf.csv'
n = data['value'].size
fr = front_range(n)
br = back_range(n)

Squib::Deck.new(width: CARD_W, height: CARD_H, cards: n * 2) do
  background color: :white, range: :all

  # おもて
  rect x: tx(USABLE_X), y: ty(3), width: '18mm', height: '10mm',
       stroke_color: :black, stroke_width: 1.3, range: fr
  text str: interleave(data['value'], nil), x: tx(USABLE_X), y: ty(3), width: '18mm', height: '10mm',
       font: "#{FONT} bold 15", align: :center, valign: :middle, range: fr
  png file: interleave(data['image'].map { |i| "#{i}.png" }, nil),
      x: tx((TRIM_W - PORTRAIT_SIZE) / 2), y: ty(15), width: "#{PORTRAIT_SIZE}mm", height: "#{PORTRAIT_SIZE}mm"
  text str: interleave(data['turf_role'], nil), x: tx(USABLE_X), y: ty(45), width: "#{USABLE_W}mm", height: '9mm',
       font: "#{FONT} bold 14", align: :center, valign: :middle, range: fr
  text str: interleave(data['turf_flavor'], nil), x: tx(USABLE_X), y: ty(55), width: "#{USABLE_W}mm", height: '9mm',
       font: "#{FONT} 7.5", align: :center, valign: :middle, color: '#737373', range: fr

  # うら(共通デザイン)
  rect x: tx(3), y: ty(3), width: "#{TRIM_W - 6}mm", height: "#{TRIM_H - 6}mm",
       stroke_color: :black, stroke_width: 1.5, range: br
  text str: 'テッペン', x: tx(USABLE_X), y: ty(TRIM_H / 2 - 8), width: "#{USABLE_W}mm", height: '16mm',
       font: "#{FONT} bold 20", align: :center, valign: :middle, range: br
  text str: 'ナワバリ', x: tx(USABLE_X), y: ty(TRIM_H / 2 + 8), width: "#{USABLE_W}mm", height: '8mm',
       font: "#{FONT} 9", align: :center, valign: :middle, color: '#737373', range: br

  save_pdf(**pdf_opts('02_turf_pair'))
end
puts "02_turf_pair: #{n} pairs (#{n * 2} pages)"
