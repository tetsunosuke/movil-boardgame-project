#!/usr/bin/env ruby
# encoding: utf-8
# 「私の能力ランキング」入稿用カード印刷データ(Squib版)。gr@phic「トレーディングカード小」想定。
#   仕上がり: W59×H86mm / 塗り足し3mm / アートボード W65×H92mm
#   入稿データの都合上、各カードの「表」と「直後にその裏」が隣り合う順番で並べる
#   (1表,1裏,2表,2裏,... という並び。1つのdeckの中で偶数indexに表、奇数indexに裏を描画する)
require 'squib'

BLEED = 3.0
TRIM_W = 59.0
TRIM_H = 86.0
MARGIN = 3.5
CARD_W = "#{TRIM_W + 2 * BLEED}mm"
CARD_H = "#{TRIM_H + 2 * BLEED}mm"
FONT = 'Yu Gothic'
USABLE_W = TRIM_W - 2 * MARGIN
USABLE_X = MARGIN

def tx(mm) = "#{mm + BLEED}mm"
def ty(mm) = "#{mm + BLEED}mm"

def pdf_opts(name)
  { file: "#{name}.pdf", crop_marks: true, trim: "#{BLEED}mm",
    width: '210mm', height: '297mm', margin: '8mm', gap: '3mm' }
end

# front_arr(長さn)とback_arr(長さn、または単一値)を [front0,back0,front1,back1,...] の順に
# 交互配置した長さ2nの配列を作る。back_arrがArrayでなければ同じ値をn回複製して使う。
def interleave(front_arr, back_arr)
  n = (front_arr.is_a?(Array) ? front_arr : back_arr).size
  front_arr = Array.new(n, front_arr) unless front_arr.is_a?(Array)
  back_arr = Array.new(n, back_arr) unless back_arr.is_a?(Array)
  Array.new(n * 2) { |i| i.even? ? front_arr[i / 2] : back_arr[i / 2] }
end

def front_range(n) = (0...(n * 2)).step(2).to_a
def back_range(n) = (1...(n * 2)).step(2).to_a

def generic_back_common(label, range:)
  # 共通裏面の固定要素(データに依存しない部分)。range必須(裏面indexのみに限定するため)。
  rect x: tx(2), y: ty(2), width: "#{TRIM_W - 4}mm", height: "#{TRIM_H - 4}mm",
       stroke_color: :black, stroke_width: 2, range: range
  rect x: tx(4), y: ty(4), width: "#{TRIM_W - 8}mm", height: "#{TRIM_H - 8}mm",
       stroke_color: :black, stroke_width: 0.5, range: range
  rect x: tx(USABLE_X), y: ty(36), width: "#{USABLE_W}mm", height: '12mm', fill_color: :black, range: range
  text str: label, x: tx(USABLE_X), y: ty(36), width: "#{USABLE_W}mm", height: '12mm',
       font: "#{FONT} bold 12", align: :center, valign: :middle, color: :white, range: range
  text str: '私の能力ランキング', x: tx(USABLE_X), y: ty(76), width: "#{USABLE_W}mm", height: '5mm',
       font: "#{FONT} 6", align: :center, color: '#999999', range: range
end

# ── 1〜2. 能力カード おもて/うら (1表,1裏,2表,2裏,... 60枚) ──
data = Squib.csv file: 'data/ability_front.csv'
n = data['name'].size
is_kiso = data['band_type'].map { |t| t == 'k' }
back_label = is_kiso.map { |k| k ? '社会人基礎力' : 'その他の能力' }
back_sub = is_kiso.map { |k| k ? '12枚の山' : '18枚の山' }
fr = front_range(n)
br = back_range(n)

Squib::Deck.new(width: CARD_W, height: CARD_H, cards: n * 2) do
  background color: :white, range: :all

  # おもて
  rect x: tx(USABLE_X), y: ty(2), width: '25mm', height: '5.5mm',
       stroke_color: :black, stroke_width: 1,
       fill_color: interleave(is_kiso.map { |k| k ? :black : :white }, nil), range: fr
  text str: interleave(data['band_label'], nil), x: tx(USABLE_X), y: ty(2), width: '25mm', height: '5.5mm',
       font: "#{FONT} bold 8", align: :center, valign: :middle,
       color: interleave(is_kiso.map { |k| k ? :white : :black }, nil), range: fr
  text str: interleave(data['code'], nil), x: tx(31), y: ty(2), width: "#{USABLE_W - 28}mm", height: '5.5mm',
       font: "#{FONT} bold 11", align: :right, valign: :middle, range: fr
  text str: interleave(data['name'], nil), x: tx(USABLE_X), y: ty(11), width: "#{USABLE_W}mm", height: '15mm',
       font: "#{FONT} bold 15", range: fr
  line x1: tx(USABLE_X), y1: ty(28), x2: tx(USABLE_X + 12), y2: ty(28), stroke_width: 1.5, range: fr
  text str: interleave(data['definition'], nil), x: tx(USABLE_X), y: ty(31), width: "#{USABLE_W}mm", height: '33mm',
       font: "#{FONT} 9", range: fr
  text str: '私の能力ランキング', x: tx(USABLE_X), y: ty(78), width: "#{USABLE_W}mm", height: '5mm',
       font: "#{FONT} 6", color: '#999999', range: fr

  # うら
  rect x: tx(2), y: ty(2), width: "#{TRIM_W - 4}mm", height: "#{TRIM_H - 4}mm",
       stroke_color: :black, stroke_width: 2, range: br
  rect x: tx(4), y: ty(4), width: "#{TRIM_W - 8}mm", height: "#{TRIM_H - 8}mm",
       stroke_color: :black, stroke_width: 0.5, range: br
  rect x: tx(USABLE_X), y: ty(31), width: "#{USABLE_W}mm", height: '22mm',
       fill_color: interleave(nil, is_kiso.map { |k| k ? :black : :white }), range: br
  text str: interleave(nil, back_label), x: tx(USABLE_X), y: ty(36), width: "#{USABLE_W}mm", height: '8mm',
       font: "#{FONT} bold 13", align: :center, valign: :middle,
       color: interleave(nil, is_kiso.map { |k| k ? :white : :black }), range: br
  text str: interleave(nil, back_sub), x: tx(USABLE_X), y: ty(45), width: "#{USABLE_W}mm", height: '6mm',
       font: "#{FONT} 7.5", align: :center, valign: :middle,
       color: interleave(nil, is_kiso.map { |k| k ? :white : :black }), range: br

  save_pdf(**pdf_opts('01_ability_pair'))
end
puts "01_ability_pair: #{n} pairs (#{n * 2} pages)"

# ── 3〜4. 自信度カード おもて/うら (12組=24枚) ────────────────
data = Squib.csv file: 'data/tier.csv'
n = data['letter'].size
fr = front_range(n)
br = back_range(n)

Squib::Deck.new(width: CARD_W, height: CARD_H, cards: n * 2) do
  background color: :white, range: :all

  text str: interleave(data['letter'], nil), x: tx(6), y: ty(20), width: '30mm', height: '25mm',
       font: "#{FONT} bold 58", align: :right, valign: :middle, range: fr
  text str: interleave(data['num'], nil), x: tx(37), y: ty(30), width: '14mm', height: '15mm',
       font: "#{FONT} bold 24", align: :left, valign: :middle, range: fr
  4.times do |bar_i|
    filled = data["bar#{bar_i + 1}"].map { |v| v.to_i == 1 }
    rect x: tx(20 + bar_i * 6), y: ty(53), width: '5mm', height: '2.5mm',
         stroke_color: :black, stroke_width: 1,
         fill_color: interleave(filled.map { |f| f ? :black : :white }, nil), range: fr
  end
  text str: interleave(data['cap'], nil), x: tx(USABLE_X), y: ty(60), width: "#{USABLE_W}mm", height: '8mm',
       font: "#{FONT} 10", align: :center, valign: :middle, range: fr
  text str: '番号が小さいほど上位', x: tx(USABLE_X), y: ty(70), width: "#{USABLE_W}mm", height: '6mm',
       font: "#{FONT} 6.5", align: :center, valign: :middle, color: '#999999', range: fr

  generic_back_common('自信度', range: br)

  save_pdf(**pdf_opts('02_tier_pair'))
end
puts "02_tier_pair: #{n} pairs (#{n * 2} pages)"

# ── 5〜6. 番号カード・プレイヤー用 おもて/うら (36組=72枚) ────
data = Squib.csv file: 'data/number_player.csv', explode: 'Copies'
n = data['n'].size
fr = front_range(n)
br = back_range(n)

Squib::Deck.new(width: CARD_W, height: CARD_H, cards: n * 2) do
  background color: :white, range: :all
  is_white = data['bg_hex'].map { |c| c.upcase == '#FFFFFF' }

  circle x: tx(TRIM_W / 2), y: ty(35), radius: '18mm',
         fill_color: interleave(data['bg_hex'], nil),
         stroke_color: :black, stroke_width: interleave(is_white.map { |w| w ? 1 : 0 }, 0), range: fr
  text str: interleave(data['n'], nil), x: tx(USABLE_X), y: ty(20), width: "#{USABLE_W}mm", height: '30mm',
       font: "#{FONT} bold 56", align: :center, valign: :middle,
       color: interleave(data['fg_hex'], nil), range: fr
  text str: interleave(data['color_name'], nil), x: tx(USABLE_X), y: ty(58), width: "#{USABLE_W}mm", height: '8mm',
       font: "#{FONT} bold 13", align: :center, valign: :middle, range: fr
  text str: interleave(data['hint'], nil), x: tx(USABLE_X), y: ty(70), width: "#{USABLE_W}mm", height: '6mm',
       font: "#{FONT} 7", align: :center, valign: :middle, color: '#999999', range: fr

  generic_back_common('番号（プレイヤー用）', range: br)

  save_pdf(**pdf_opts('03_number_player_pair'))
end
puts "03_number_player_pair: #{n} pairs (#{n * 2} pages)"

# ── 7〜8. 番号カード・場用 おもて/うら (6組=12枚) ─────────────
data = Squib.csv file: 'data/number_board.csv'
n = data['n'].size
fr = front_range(n)
br = back_range(n)

Squib::Deck.new(width: CARD_W, height: CARD_H, cards: n * 2) do
  is_white = data['is_white'].map { |v| v.to_i == 1 }
  background color: interleave(data['bg_hex'], :white), range: :all
  rect x: tx(1), y: ty(1), width: "#{TRIM_W - 2}mm", height: "#{TRIM_H - 2}mm",
       stroke_color: interleave(data['fg_hex'], nil),
       stroke_width: interleave(is_white.map { |w| w ? 1.5 : 0 }, 0), range: fr
  text str: '枠番', x: tx(USABLE_X), y: ty(4), width: "#{USABLE_W}mm", height: '6mm',
       font: "#{FONT} 8", align: :center, valign: :middle,
       color: interleave(data['fg_hex'], nil), range: fr
  text str: interleave(data['n'], nil), x: tx(USABLE_X), y: ty(28), width: "#{USABLE_W}mm", height: '34mm',
       font: "#{FONT} bold 86", align: :center, valign: :middle,
       color: interleave(data['fg_hex'], nil), range: fr
  text str: interleave(data['color_name'], nil), x: tx(USABLE_X), y: ty(66), width: "#{USABLE_W}mm", height: '10mm',
       font: "#{FONT} bold 15", align: :center, valign: :middle,
       color: interleave(data['fg_hex'], nil), range: fr

  generic_back_common('番号（場用）', range: br)

  save_pdf(**pdf_opts('04_number_board_pair'))
end
puts "04_number_board_pair: #{n} pairs (#{n * 2} pages)"
