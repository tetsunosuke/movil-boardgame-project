#!/usr/bin/env ruby
# encoding: utf-8
# 「キャリア・アイランド」プロトタイプ用カード印刷データ(Squib版)。自分でA4を切って
# スリーブ+厚紙で実際にプレイできるようにするためのもの。塗り足しなし、実寸63×88mm。
# 全カード種別を1つの連続したデッキとして描画し、A4 1枚=9枚のグリッドを型の境界を
# またいで隙間なく詰める(型ごとに別デッキ/別PDFにすると、型の切り替わり目でグリッドが
# 端数のまま次のPDFに移ってしまい、印刷時に無駄な余白ページが発生するため)。
require File.expand_path(File.join(Dir.pwd, '..', '_lib', 'squib_common'))
include Squibcommon
include Squibcommon::Proto
require File.expand_path(File.join(Dir.pwd, 'card_layout'))

FONT = 'Yu Gothic'

def draw_coord_front_p(data, range)
  text str: data['label'], x: tx(USABLE_X), y: ty(20), width: "#{USABLE_W}mm", height: '35mm',
       font: "#{FONT} bold 60", align: :center, valign: :middle, range: range
  text str: '座標カード', x: tx(USABLE_X), y: ty(72), width: "#{USABLE_W}mm", height: '8mm',
       font: "#{FONT} 14", align: :center, valign: :middle, color: '#555555', range: range
end

def draw_love_luck_front_p(data, range)
  text str: data['label'], x: tx(USABLE_X), y: ty(25), width: "#{USABLE_W}mm", height: '30mm',
       font: "#{FONT} bold 40", align: :center, valign: :middle, range: range
  text str: 'キズナ抽選カード', x: tx(USABLE_X), y: ty(72), width: "#{USABLE_W}mm", height: '8mm',
       font: "#{FONT} 14", align: :center, valign: :middle, color: '#555555', range: range
end

# [type, 裏面ラベル(未使用。入稿用スクリプトとテーブル構造を揃えるため残す)](おもて面のフォント/レイアウトは card_layout.rb の FRONT_STYLES)
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

items = []
TYPES.each do |(ctype, _back_label)|
  data = Squib.csv file: "data/#{ctype}.csv", explode: 'Copies'
  items << { kind: :generic, ctype: ctype, data: data, n: data['name'].size }
end

dilemma_data = Squib.csv file: 'data/dilemma.csv'
items << { kind: :dilemma, ctype: 'dilemma', data: dilemma_data, n: dilemma_data['name'].size }

coord_data = Squib.csv file: 'data/coord_draw.csv'
items << { kind: :coord, ctype: 'coord_draw', data: coord_data, n: coord_data['label'].size }

love_luck_data = Squib.csv file: 'data/love_luck.csv', explode: 'Copies'
items << { kind: :love_luck, ctype: 'love_luck', data: love_luck_data, n: love_luck_data['label'].size }

total = items.sum { |it| it[:n] }

offset = 0
Squib::Deck.new(width: CARD_W, height: CARD_H, cards: total) do
  background color: :white
  cut_guide

  items.each do |it|
    r = seq_range(offset, it[:n])
    padded = pad_data(it[:data], total, offset)
    case it[:kind]
    when :generic
      draw_front(it[:ctype], padded, r, ->(a) { a })
    when :dilemma
      draw_dilemma_front(padded, r, ->(a) { a })
    when :coord
      draw_coord_front_p(padded, r)
    when :love_luck
      draw_love_luck_front_p(padded, r)
    end
    offset += it[:n]
  end

  save_pdf(**pdf_opts('career_island_proto_all'))
end

puts "combined proto deck: #{total} cards / #{(total / 9.0).ceil} pages (9枚/ページ, 型の境界なし)"
offset = 0
items.each do |it|
  puts "  #{it[:ctype]}: #{it[:n]} cards (index #{offset}..#{offset + it[:n] - 1})"
  offset += it[:n]
end
print_layout_report
