#!/usr/bin/env ruby
# encoding: utf-8
# 「キャリア・アイランド」入稿用カード印刷データ(Squib版)。gr@phic「トレーディングカード小」想定。
# 表→裏が隣接する順(1表,1裏,2表,2裏,...)で並べる。
require File.expand_path(File.join(Dir.pwd, '..', '_lib', 'squib_common'))
include Squibcommon
include Squibcommon::Print
require File.expand_path(File.join(Dir.pwd, 'card_layout'))

FONT = 'Yu Gothic'

def draw_back(label, range)
  rect x: tx(2), y: ty(2), width: "#{TRIM_W - 4}mm", height: "#{TRIM_H - 4}mm",
       stroke_color: :black, stroke_width: 2, range: range
  rect x: tx(4), y: ty(4), width: "#{TRIM_W - 8}mm", height: "#{TRIM_H - 8}mm",
       stroke_color: :black, stroke_width: 0.5, range: range
  rect x: tx(USABLE_X), y: ty(36), width: "#{USABLE_W}mm", height: '12mm', fill_color: :black, range: range
  text str: label, x: tx(USABLE_X), y: ty(36), width: "#{USABLE_W}mm", height: '12mm',
       font: "#{FONT} bold 13", align: :center, valign: :middle, color: :white, range: range
  text str: 'キャリア・アイランド', x: tx(USABLE_X), y: ty(73.5), width: "#{USABLE_W}mm", height: '6mm',
       font: "#{FONT} 9", align: :center, valign: :middle, color: '#777777', range: range
end

# [type, 裏面ラベル](おもて面のフォント/レイアウトは card_layout.rb の FRONT_STYLES)
TYPES = [
  ['trouble', 'イベント'],
  ['life', 'イベント'],
  ['role', '役職'],
  ['age', '年代'],
  ['goal', 'キャリア目標'],
  ['token', 'カード'],
  ['labor', 'Labor（仕事）'],
  ['learning', 'Learning（学習）'],
  ['leisure', 'Leisure（余暇）'],
  ['love', 'Love（関係）'],
]

TYPES.each_with_index do |(ctype, back_label), i|
  data = Squib.csv file: "data/#{ctype}.csv", explode: 'Copies'
  n = data['name'].size
  fr = front_range(n)
  br = back_range(n)

  Squib::Deck.new(width: CARD_W, height: CARD_H, cards: n * 2) do
    background color: :white, range: :all
    draw_front(ctype, data, fr, ->(a) { interleave(a, nil) })
    draw_back(back_label, br)
    save_pdf(**pdf_opts(format('%02d_%s_pair', i + 1, ctype)))
  end
  puts "#{ctype}_pair: #{n} pairs (#{n * 2} pages)"
end

# ── ジレンマ(専用レイアウト、5組=10枚) ────────────────────────
data = Squib.csv file: 'data/dilemma.csv'
n = data['name'].size
fr = front_range(n)
br = back_range(n)

Squib::Deck.new(width: CARD_W, height: CARD_H, cards: n * 2) do
  background color: :white, range: :all

  draw_dilemma_front(data, fr, ->(a) { interleave(a, nil) })

  draw_back('イベント', br)
  save_pdf(**pdf_opts('11_dilemma_pair'))
end
puts "dilemma_pair: #{n} pairs (#{n * 2} pages)"

# ── 座標カード・抽選用(A-1〜E-5の25枚、裏面なし) ──────────────
data = Squib.csv file: 'data/coord_draw.csv'
n = data['label'].size

Squib::Deck.new(width: CARD_W, height: CARD_H, cards: n) do
  background color: :white
  text str: data['label'], x: tx(USABLE_X), y: ty(20), width: "#{USABLE_W}mm", height: '35mm',
       font: "#{FONT} bold 60", align: :center, valign: :middle
  text str: '座標カード', x: tx(USABLE_X), y: ty(72), width: "#{USABLE_W}mm", height: '8mm',
       font: "#{FONT} 14", align: :center, valign: :middle, color: '#555555'
  save_pdf(**pdf_opts('12_coord_draw'))
end
puts "coord_draw: #{n} cards (no back)"

# ── キズナ抽選カード(Loveマス経験後に引く5枚、当たり2/ハズレ3、裏面なし) ──
data = Squib.csv file: 'data/love_luck.csv', explode: 'Copies'
n = data['label'].size

Squib::Deck.new(width: CARD_W, height: CARD_H, cards: n) do
  background color: :white
  text str: data['label'], x: tx(USABLE_X), y: ty(25), width: "#{USABLE_W}mm", height: '30mm',
       font: "#{FONT} bold 40", align: :center, valign: :middle
  text str: 'キズナ抽選カード', x: tx(USABLE_X), y: ty(72), width: "#{USABLE_W}mm", height: '8mm',
       font: "#{FONT} 14", align: :center, valign: :middle, color: '#555555'
  save_pdf(**pdf_opts('13_love_luck'))
end
puts "love_luck: #{n} cards (no back)"

print_layout_report
