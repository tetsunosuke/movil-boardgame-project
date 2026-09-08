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

FONT = 'Yu Gothic'

def draw_generic_front_p(data, range)
  has_effect = data['effect_label'].map { |v| !v.to_s.empty? }

  text str: data['icon'], x: tx(USABLE_W - 6), y: ty(1), width: '13mm', height: '6mm',
       font: "#{FONT} 9", align: :right, range: range
  rect x: tx(USABLE_X), y: ty(2), width: '24mm', height: '5mm', stroke_color: :black, stroke_width: 1, range: range
  text str: data['badge'], x: tx(USABLE_X), y: ty(2), width: '24mm', height: '5mm',
       font: "#{FONT} bold 6.5", align: :center, valign: :middle, range: range
  text str: data['name'], x: tx(USABLE_X), y: ty(9), width: "#{USABLE_W}mm", height: '25mm',
       font: "#{FONT} bold 10", range: range
  text str: data['prompt'], x: tx(USABLE_X), y: ty(35), width: "#{USABLE_W}mm", height: '13mm',
       font: "#{FONT} 6.8", color: '#555555', range: range
  rect x: tx(USABLE_X), y: ty(49), width: "#{USABLE_W}mm", height: '20mm',
       stroke_color: has_effect.map { |e| e ? :black : '#0000' }, stroke_width: 1.2, range: range
  text str: data['effect_label'], x: tx(USABLE_X + 1), y: ty(51), width: "#{USABLE_W - 2}mm", height: '4mm',
       font: "#{FONT} bold 5.5", align: :center, color: '#555555', range: range
  text str: data['effect_value'], x: tx(USABLE_X + 2), y: ty(55), width: "#{USABLE_W - 4}mm", height: '13mm',
       font: "#{FONT} bold 7.5", align: :left, range: range
  text str: data['bonus'], x: tx(USABLE_X), y: ty(70), width: "#{USABLE_W}mm", height: '12mm',
       font: "#{FONT} 6", align: :center, color: '#555555', range: range
  text str: data['setup'], x: tx(USABLE_X), y: ty(70), width: "#{USABLE_W}mm", height: '12mm',
       font: "#{FONT} 6", align: :center, color: '#555555', range: range
end

# role/age/goal/token共通のおもて描画。タイトルをカード中央付近に大きめ・センタリングで配置する。
def draw_centered_front_p(data, range, title_font_size)
  has_effect = data['effect_label'].map { |v| !v.to_s.empty? }

  rect x: tx(USABLE_X), y: ty(2), width: '24mm', height: '5mm', stroke_color: :black, stroke_width: 1, range: range
  text str: data['badge'], x: tx(USABLE_X), y: ty(2), width: '24mm', height: '5mm',
       font: "#{FONT} bold 6.5", align: :center, valign: :middle, range: range
  text str: data['name'], x: tx(USABLE_X), y: ty(10), width: "#{USABLE_W}mm", height: '30mm',
       font: "#{FONT} bold #{title_font_size}", align: :center, valign: :middle, range: range
  rect x: tx(USABLE_X), y: ty(49), width: "#{USABLE_W}mm", height: '20mm',
       stroke_color: has_effect.map { |e| e ? :black : '#0000' }, stroke_width: 1.2, range: range
  text str: data['effect_label'], x: tx(USABLE_X + 1), y: ty(51), width: "#{USABLE_W - 2}mm", height: '4mm',
       font: "#{FONT} bold 5.5", align: :center, color: '#555555', range: range
  text str: data['effect_value'], x: tx(USABLE_X + 2), y: ty(55), width: "#{USABLE_W - 4}mm", height: '13mm',
       font: "#{FONT} bold 7.5", align: :left, range: range
  text str: data['setup'], x: tx(USABLE_X), y: ty(70), width: "#{USABLE_W}mm", height: '12mm',
       font: "#{FONT} 6", align: :center, color: '#555555', range: range
end

def draw_dilemma_front_p(data, range)
  rect x: tx(USABLE_X), y: ty(2), width: '20mm', height: '5mm', stroke_color: :black, stroke_width: 1, range: range
  text str: data['badge'], x: tx(USABLE_X), y: ty(2), width: '20mm', height: '5mm',
       font: "#{FONT} bold 6.5", align: :center, valign: :middle, range: range
  text str: data['name'], x: tx(USABLE_X), y: ty(9), width: "#{USABLE_W}mm", height: '13mm',
       font: "#{FONT} bold 11", range: range
  text str: data['opt_a_label'], x: tx(USABLE_X), y: ty(26), width: "#{USABLE_W}mm", height: '5mm',
       font: "#{FONT} bold 8", range: range
  text str: data['opt_a_text'], x: tx(USABLE_X), y: ty(32), width: "#{USABLE_W}mm", height: '20mm',
       font: "#{FONT} 7", range: range
  text str: data['opt_b_label'], x: tx(USABLE_X), y: ty(55), width: "#{USABLE_W}mm", height: '5mm',
       font: "#{FONT} bold 8", range: range
  text str: data['opt_b_text'], x: tx(USABLE_X), y: ty(61), width: "#{USABLE_W}mm", height: '20mm',
       font: "#{FONT} 7", range: range
end

def draw_coord_front_p(data, range)
  text str: data['label'], x: tx(USABLE_X), y: ty(20), width: "#{USABLE_W}mm", height: '35mm',
       font: "#{FONT} bold 44", align: :center, valign: :middle, range: range
  text str: '座標カード', x: tx(USABLE_X), y: ty(74), width: "#{USABLE_W}mm", height: '8mm',
       font: "#{FONT} 6.5", align: :center, color: '#555555', range: range
end

def draw_love_luck_front_p(data, range)
  text str: data['label'], x: tx(USABLE_X), y: ty(25), width: "#{USABLE_W}mm", height: '30mm',
       font: "#{FONT} bold 20", align: :center, valign: :middle, range: range
  text str: '絆抽選カード', x: tx(USABLE_X), y: ty(74), width: "#{USABLE_W}mm", height: '8mm',
       font: "#{FONT} 6.5", align: :center, color: '#555555', range: range
end

# [type, 裏面ラベル(未使用。入稿用スクリプトとテーブル構造を揃えるため残す), :left/:center, センタリング時のタイトルフォントサイズ]
TYPES = [
  ['trouble', 'イベント', :left, nil],
  ['life', 'イベント', :left, nil],
  ['role', '役職', :center, 13],
  ['age', '年代', :center, 13],
  ['goal', 'キャリア目標', :center, 13],
  ['token', 'カード', :center, 22],
  ['labor', 'Labor（仕事）', :left, nil],
  ['learning', 'Learning（学習）', :left, nil],
  ['leisure', 'Leisure（余暇）', :left, nil],
  ['love', 'Love（関係）', :left, nil],
]

items = []
TYPES.each do |(ctype, _back_label, mode, title_font_size)|
  data = Squib.csv file: "data/#{ctype}.csv", explode: 'Copies'
  items << { kind: :generic, ctype: ctype, mode: mode, title_font_size: title_font_size,
             data: data, n: data['name'].size }
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
      if it[:mode] == :center
        draw_centered_front_p(padded, r, it[:title_font_size])
      else
        draw_generic_front_p(padded, r)
      end
    when :dilemma
      draw_dilemma_front_p(padded, r)
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
