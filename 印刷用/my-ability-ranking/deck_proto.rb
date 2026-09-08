#!/usr/bin/env ruby
# encoding: utf-8
# 「私の能力ランキング」プロトタイプ用カード印刷データ(Squib版)。
# 自分でA4用紙を切り、スリーブ+厚紙で実際にプレイできるようにするためのもの。
#   - 塗り足しなし、実寸(63×88mm=スリーブに合うトレーディングカードサイズ)
#   - A4から取れる枚数を最大化(3列×3行=9枚/ページ)、型の境界をまたいで隙間なく詰める
#   - 白黒しかない型(能力・自信度)とカラーを使う型(番号カード)は別デッキのまま
#     (白黒ページをカラープリンタで刷ってインクを無駄にしないため、これは維持する)
#   - トンボの代わりに、はさみで切りやすい単純な外枠線をガイドとして入れる
require File.expand_path(File.join(Dir.pwd, '..', '_lib', 'squib_common'))
include Squibcommon
include Squibcommon::Proto

FONT = 'Yu Gothic'

def draw_ability_front_p(data, range)
  is_kiso = data['band_type'].map { |t| t == 'k' }

  rect x: tx(USABLE_X), y: ty(3.5), width: '27mm', height: '5.5mm',
       stroke_color: :black, stroke_width: 1,
       fill_color: is_kiso.map { |k| k ? :black : :white }, range: range
  text str: data['band_label'], x: tx(USABLE_X), y: ty(3.5), width: '27mm', height: '5.5mm',
       font: "#{FONT} bold 8", align: :center, valign: :middle,
       color: is_kiso.map { |k| k ? :white : :black }, range: range
  text str: data['code'], x: tx(33), y: ty(3.5), width: '26.5mm', height: '5.5mm',
       font: "#{FONT} bold 11", align: :right, valign: :middle, range: range
  text str: data['name'], x: tx(USABLE_X), y: ty(13), width: "#{USABLE_W}mm", height: '15mm',
       font: "#{FONT} bold 15", range: range
  line x1: tx(USABLE_X), y1: ty(30), x2: tx(USABLE_X + 12), y2: ty(30), stroke_width: 1.5, range: range
  text str: data['definition'], x: tx(USABLE_X), y: ty(33), width: "#{USABLE_W}mm", height: '35mm',
       font: "#{FONT} 9", range: range
  text str: data['name'].map { '私の能力ランキング' }, x: tx(USABLE_X), y: ty(80), width: "#{USABLE_W}mm", height: '5mm',
       font: "#{FONT} 6", color: '#999999', range: range
end

def draw_tier_front_p(data, range)
  text str: data['letter'], x: tx(10), y: ty(22), width: '30mm', height: '25mm',
       font: "#{FONT} bold 58", align: :right, valign: :middle, range: range
  text str: data['num'], x: tx(41), y: ty(32), width: '14mm', height: '15mm',
       font: "#{FONT} bold 24", align: :left, valign: :middle, range: range
  4.times do |bar_i|
    filled = data["bar#{bar_i + 1}"].map { |v| v.to_i == 1 }
    rect x: tx(24 + bar_i * 6), y: ty(55), width: '5mm', height: '2.5mm',
         stroke_color: :black, stroke_width: 1,
         fill_color: filled.map { |f| f ? :black : :white }, range: range
  end
  text str: data['cap'], x: tx(USABLE_X), y: ty(62), width: "#{USABLE_W}mm", height: '8mm',
       font: "#{FONT} 10", align: :center, valign: :middle, range: range
  text str: data['letter'].map { '番号が小さいほど上位' }, x: tx(USABLE_X), y: ty(72), width: "#{USABLE_W}mm", height: '6mm',
       font: "#{FONT} 6.5", align: :center, valign: :middle, color: '#999999', range: range
end

def draw_number_player_front_p(data, range)
  is_white = data['bg_hex'].map { |c| c.to_s.upcase == '#FFFFFF' }

  circle x: tx(31.5), y: ty(35), radius: '19mm',
         fill_color: data['bg_hex'],
         stroke_color: :black, stroke_width: is_white.map { |w| w ? 1 : 0 }, range: range
  text str: data['n'], x: tx(USABLE_X), y: ty(20), width: "#{USABLE_W}mm", height: '30mm',
       font: "#{FONT} bold 60", align: :center, valign: :middle, color: data['fg_hex'], range: range
  text str: data['color_name'], x: tx(USABLE_X), y: ty(58), width: "#{USABLE_W}mm", height: '8mm',
       font: "#{FONT} bold 13", align: :center, valign: :middle, range: range
  text str: data['hint'], x: tx(USABLE_X), y: ty(75), width: "#{USABLE_W}mm", height: '6mm',
       font: "#{FONT} 7", align: :center, valign: :middle, color: '#999999', range: range
end

def draw_number_board_front_p(data, range)
  is_white = data['is_white'].map { |v| v.to_i == 1 }

  background color: data['bg_hex'], range: range
  rect x: tx(3), y: ty(3), width: '57mm', height: '82mm',
       stroke_color: data['fg_hex'], stroke_width: is_white.map { |w| w ? 1.5 : 0 }, range: range
  text str: data['n'].map { '枠番' }, x: tx(USABLE_X), y: ty(5.5), width: "#{USABLE_W}mm", height: '6mm',
       font: "#{FONT} 8", align: :center, valign: :middle, color: data['fg_hex'], range: range
  text str: data['n'], x: tx(USABLE_X), y: ty(30), width: "#{USABLE_W}mm", height: '35mm',
       font: "#{FONT} bold 90", align: :center, valign: :middle, color: data['fg_hex'], range: range
  text str: data['color_name'], x: tx(USABLE_X), y: ty(68), width: "#{USABLE_W}mm", height: '10mm',
       font: "#{FONT} bold 15", align: :center, valign: :middle, color: data['fg_hex'], range: range
end

def build_combined_deck(items, out_name)
  total = items.sum { |it| it[:n] }
  offset = 0
  Squib::Deck.new(width: CARD_W, height: CARD_H, cards: total) do
    background color: :white
    cut_guide

    items.each do |it|
      r = seq_range(offset, it[:n])
      padded = pad_data(it[:data], total, offset)
      send(it[:draw], padded, r)
      offset += it[:n]
    end

    save_pdf(**pdf_opts(out_name))
  end
  puts "#{out_name}: #{total} cards / #{(total / 9.0).ceil} pages (9枚/ページ, 型の境界なし)"
  offset = 0
  items.each do |it|
    puts "  #{it[:label]}: #{it[:n]} cards (index #{offset}..#{offset + it[:n] - 1})"
    offset += it[:n]
  end
end

# ── 白黒グループ(能力カード・自信度カード) ────────────────────
ability_data = Squib.csv file: 'data/ability_front.csv'
tier_data = Squib.csv file: 'data/tier.csv'
build_combined_deck(
  [
    { label: 'ability', data: ability_data, n: ability_data['name'].size, draw: :draw_ability_front_p },
    { label: 'tier', data: tier_data, n: tier_data['letter'].size, draw: :draw_tier_front_p },
  ],
  'bw_proto_all'
)

# ── カラーグループ(番号カード・プレイヤー用/場用) ──────────────
number_player_data = Squib.csv file: 'data/number_player.csv', explode: 'Copies'
number_board_data = Squib.csv file: 'data/number_board.csv'
build_combined_deck(
  [
    { label: 'number_player', data: number_player_data, n: number_player_data['n'].size,
      draw: :draw_number_player_front_p },
    { label: 'number_board', data: number_board_data, n: number_board_data['n'].size,
      draw: :draw_number_board_front_p },
  ],
  'color_proto_all'
)
