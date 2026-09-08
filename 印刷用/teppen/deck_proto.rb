#!/usr/bin/env ruby
# encoding: utf-8
# 「テッペン」プロトタイプ用カード印刷データ(Squib版)。自分でA4を切ってスリーブ+厚紙で
# 実際にプレイできるようにするためのもの。塗り足しなし、実寸63×88mm、A4最大枚数。
# 手下カード・ナワバリカードを1つの連続したデッキとして描画し、A4 1枚=9枚のグリッドを
# 型の境界をまたいで隙間なく詰める(印刷時に無駄な余白ページが出ないようにするため)。
require File.expand_path(File.join(Dir.pwd, '..', '_lib', 'squib_common'))
include Squibcommon
include Squibcommon::Proto

FONT = 'Yu Gothic'
FONT_STENCIL = 'Rockwell'
IMG_DIR = 'images'
Squib.configure(img_dir: IMG_DIR)
PORTRAIT_SIZE = 28.0  # mm

def draw_member_front_p(data, range)
  has_effect = data['effect'].map { |e| !e.to_s.empty? }

  text str: data['number'], x: tx(USABLE_X), y: ty(2), width: '14mm', height: '10mm',
       font: "#{FONT_STENCIL} bold 26", align: :left, valign: :middle, range: range
  png file: data['image'].map { |i| i.nil? ? nil : "#{i}.png" },
      x: tx((TRIM_W - PORTRAIT_SIZE) / 2), y: ty(13), width: "#{PORTRAIT_SIZE}mm", height: "#{PORTRAIT_SIZE}mm",
      range: range
  text str: data['role'], x: tx(USABLE_X), y: ty(43), width: "#{USABLE_W}mm", height: '9mm',
       font: "#{FONT} bold 16", align: :center, valign: :middle, range: range
  text str: data['flavor'], x: tx(USABLE_X), y: ty(52), width: "#{USABLE_W}mm", height: '7mm',
       font: "#{FONT} 7.5", align: :center, valign: :middle, color: '#737373', range: range
  rect x: tx(USABLE_X), y: ty(60), width: "#{USABLE_W}mm", height: '18mm',
       stroke_color: has_effect.map { |e| e ? :black : '#0000' }, stroke_width: 1.3, range: range
  text str: has_effect.map { |e| e ? '特殊効果' : '' },
       x: tx(USABLE_X + 2), y: ty(62), width: "#{USABLE_W - 4}mm", height: '4mm',
       font: "#{FONT} bold 6", color: '#737373', range: range
  text str: data['effect'], x: tx(USABLE_X + 2), y: ty(67), width: "#{USABLE_W - 4}mm", height: '10mm',
       font: "#{FONT} 6.8", range: range
end

def draw_turf_front_p(data, range)
  rect x: tx(USABLE_X), y: ty(3), width: '18mm', height: '10mm', stroke_color: :black, stroke_width: 1.3, range: range
  text str: data['value'], x: tx(USABLE_X), y: ty(3), width: '18mm', height: '10mm',
       font: "#{FONT} bold 15", align: :center, valign: :middle, range: range
  png file: data['image'].map { |i| i.nil? ? nil : "#{i}.png" },
      x: tx((TRIM_W - PORTRAIT_SIZE) / 2), y: ty(15), width: "#{PORTRAIT_SIZE}mm", height: "#{PORTRAIT_SIZE}mm",
      range: range
  text str: data['turf_role'], x: tx(USABLE_X), y: ty(45), width: "#{USABLE_W}mm", height: '9mm',
       font: "#{FONT} bold 14", align: :center, valign: :middle, range: range
  text str: data['turf_flavor'], x: tx(USABLE_X), y: ty(55), width: "#{USABLE_W}mm", height: '9mm',
       font: "#{FONT} 7.5", align: :center, valign: :middle, color: '#737373', range: range
end

member_data = Squib.csv file: 'data/member.csv', explode: 'Copies'
turf_data = Squib.csv file: 'data/turf.csv'

items = [
  { kind: :member, data: member_data, n: member_data['number'].size },
  { kind: :turf, data: turf_data, n: turf_data['value'].size },
]
total = items.sum { |it| it[:n] }

offset = 0
Squib::Deck.new(width: CARD_W, height: CARD_H, cards: total) do
  background color: :white
  cut_guide

  items.each do |it|
    r = seq_range(offset, it[:n])
    padded = pad_data(it[:data], total, offset)
    case it[:kind]
    when :member
      draw_member_front_p(padded, r)
    when :turf
      draw_turf_front_p(padded, r)
    end
    offset += it[:n]
  end

  save_pdf(**pdf_opts('teppen_proto_all'))
end

puts "combined proto deck: #{total} cards / #{(total / 9.0).ceil} pages (9枚/ページ, 型の境界なし)"
offset = 0
items.each do |it|
  puts "  #{it[:kind]}: #{it[:n]} cards (index #{offset}..#{offset + it[:n] - 1})"
  offset += it[:n]
end
