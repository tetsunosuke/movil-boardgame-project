#!/usr/bin/env ruby
# encoding: utf-8
# 「キャリア・アイランド」入稿用カード印刷データ(Squib版)。gr@phic「トレーディングカード小」想定。
# 表→裏が隣接する順(1表,1裏,2表,2裏,...)で並べる。
require File.expand_path(File.join(Dir.pwd, '..', '_lib', 'squib_common'))
include Squibcommon
include Squibcommon::Print

FONT = 'Yu Gothic'

# 汎用型(trouble/life/role/age/goal/token/labor/learning/leisure/love)共通のおもて描画。
# データに無いフィールドは空文字列なので、高さ0の要素を描くだけで実害はない。
def draw_generic_front(data, range)
  has_icon = data['icon'].map { |v| !v.to_s.empty? }
  has_prompt = data['prompt'].map { |v| !v.to_s.empty? }
  has_effect = data['effect_label'].map { |v| !v.to_s.empty? }
  has_bonus = data['bonus'].map { |v| !v.to_s.empty? }
  has_setup = data['setup'].map { |v| !v.to_s.empty? }

  text str: interleave(data['icon'], nil), x: tx(USABLE_W - 6), y: ty(1), width: '13mm', height: '6mm',
       font: "#{FONT} 9", align: :right, range: range
  rect x: tx(USABLE_X), y: ty(2), width: '24mm', height: '5mm', stroke_color: :black, stroke_width: 1, range: range
  text str: interleave(data['badge'], nil), x: tx(USABLE_X), y: ty(2), width: '24mm', height: '5mm',
       font: "#{FONT} bold 6.5", align: :center, valign: :middle, range: range
  text str: interleave(data['name'], nil), x: tx(USABLE_X), y: ty(9), width: "#{USABLE_W}mm", height: '25mm',
       font: "#{FONT} bold 10", range: range
  text str: interleave(data['prompt'], nil), x: tx(USABLE_X), y: ty(35), width: "#{USABLE_W}mm", height: '13mm',
       font: "#{FONT} 6.8", color: '#555555', range: range
  rect x: tx(USABLE_X), y: ty(49), width: "#{USABLE_W}mm", height: '20mm',
       stroke_color: interleave(has_effect.map { |e| e ? :black : '#0000' }, nil), stroke_width: 1.2, range: range
  text str: interleave(data['effect_label'], nil), x: tx(USABLE_X + 1), y: ty(51), width: "#{USABLE_W - 2}mm", height: '4mm',
       font: "#{FONT} bold 5.5", align: :center, color: '#555555', range: range
  text str: interleave(data['effect_value'], nil), x: tx(USABLE_X + 2), y: ty(55), width: "#{USABLE_W - 4}mm", height: '13mm',
       font: "#{FONT} bold 7.5", align: :left, range: range
  text str: interleave(data['bonus'], nil), x: tx(USABLE_X), y: ty(70), width: "#{USABLE_W}mm", height: '12mm',
       font: "#{FONT} 6", align: :center, color: '#555555', range: range
  text str: interleave(data['setup'], nil), x: tx(USABLE_X), y: ty(70), width: "#{USABLE_W}mm", height: '12mm',
       font: "#{FONT} 6", align: :center, color: '#555555', range: range
end

# role/age/goal/token共通のおもて描画。タイトルをカード中央付近に大きめ・センタリングで配置する。
def draw_centered_front(data, range, title_font_size)
  has_effect = data['effect_label'].map { |v| !v.to_s.empty? }

  rect x: tx(USABLE_X), y: ty(2), width: '24mm', height: '5mm', stroke_color: :black, stroke_width: 1, range: range
  text str: interleave(data['badge'], nil), x: tx(USABLE_X), y: ty(2), width: '24mm', height: '5mm',
       font: "#{FONT} bold 6.5", align: :center, valign: :middle, range: range
  text str: interleave(data['name'], nil), x: tx(USABLE_X), y: ty(10), width: "#{USABLE_W}mm", height: '30mm',
       font: "#{FONT} bold #{title_font_size}", align: :center, valign: :middle, range: range
  rect x: tx(USABLE_X), y: ty(49), width: "#{USABLE_W}mm", height: '20mm',
       stroke_color: interleave(has_effect.map { |e| e ? :black : '#0000' }, nil), stroke_width: 1.2, range: range
  text str: interleave(data['effect_label'], nil), x: tx(USABLE_X + 1), y: ty(51), width: "#{USABLE_W - 2}mm", height: '4mm',
       font: "#{FONT} bold 5.5", align: :center, color: '#555555', range: range
  text str: interleave(data['effect_value'], nil), x: tx(USABLE_X + 2), y: ty(55), width: "#{USABLE_W - 4}mm", height: '13mm',
       font: "#{FONT} bold 7.5", align: :left, range: range
  text str: interleave(data['setup'], nil), x: tx(USABLE_X), y: ty(70), width: "#{USABLE_W}mm", height: '12mm',
       font: "#{FONT} 6", align: :center, color: '#555555', range: range
end

def draw_back(label, range)
  rect x: tx(2), y: ty(2), width: "#{TRIM_W - 4}mm", height: "#{TRIM_H - 4}mm",
       stroke_color: :black, stroke_width: 2, range: range
  rect x: tx(4), y: ty(4), width: "#{TRIM_W - 8}mm", height: "#{TRIM_H - 8}mm",
       stroke_color: :black, stroke_width: 0.5, range: range
  rect x: tx(USABLE_X), y: ty(36), width: "#{USABLE_W}mm", height: '12mm', fill_color: :black, range: range
  text str: label, x: tx(USABLE_X), y: ty(36), width: "#{USABLE_W}mm", height: '12mm',
       font: "#{FONT} bold 11", align: :center, valign: :middle, color: :white, range: range
  text str: 'キャリア・アイランド', x: tx(USABLE_X), y: ty(76), width: "#{USABLE_W}mm", height: '5mm',
       font: "#{FONT} 6", align: :center, color: '#999999', range: range
end

# [type, 裏面ラベル, :left/:center, センタリング時のタイトルフォントサイズ]
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

TYPES.each_with_index do |(ctype, back_label, mode, title_font_size), i|
  data = Squib.csv file: "data/#{ctype}.csv", explode: 'Copies'
  n = data['name'].size
  fr = front_range(n)
  br = back_range(n)

  Squib::Deck.new(width: CARD_W, height: CARD_H, cards: n * 2) do
    background color: :white, range: :all
    if mode == :center
      draw_centered_front(data, fr, title_font_size)
    else
      draw_generic_front(data, fr)
    end
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

  rect x: tx(USABLE_X), y: ty(2), width: '20mm', height: '5mm', stroke_color: :black, stroke_width: 1, range: fr
  text str: interleave(data['badge'], nil), x: tx(USABLE_X), y: ty(2), width: '20mm', height: '5mm',
       font: "#{FONT} bold 6.5", align: :center, valign: :middle, range: fr
  text str: interleave(data['name'], nil), x: tx(USABLE_X), y: ty(9), width: "#{USABLE_W}mm", height: '13mm',
       font: "#{FONT} bold 11", range: fr

  text str: interleave(data['opt_a_label'], nil), x: tx(USABLE_X), y: ty(26), width: "#{USABLE_W}mm", height: '5mm',
       font: "#{FONT} bold 8", range: fr
  text str: interleave(data['opt_a_text'], nil), x: tx(USABLE_X), y: ty(32), width: "#{USABLE_W}mm", height: '20mm',
       font: "#{FONT} 7", range: fr
  text str: interleave(data['opt_b_label'], nil), x: tx(USABLE_X), y: ty(55), width: "#{USABLE_W}mm", height: '5mm',
       font: "#{FONT} bold 8", range: fr
  text str: interleave(data['opt_b_text'], nil), x: tx(USABLE_X), y: ty(61), width: "#{USABLE_W}mm", height: '20mm',
       font: "#{FONT} 7", range: fr

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
       font: "#{FONT} bold 44", align: :center, valign: :middle
  text str: '座標カード', x: tx(USABLE_X), y: ty(74), width: "#{USABLE_W}mm", height: '8mm',
       font: "#{FONT} 6.5", align: :center, color: '#555555'
  save_pdf(**pdf_opts('12_coord_draw'))
end
puts "coord_draw: #{n} cards (no back)"

# ── 絆抽選カード(Loveマス経験後に引く5枚、当たり2/ハズレ3、裏面なし) ──
data = Squib.csv file: 'data/love_luck.csv', explode: 'Copies'
n = data['label'].size

Squib::Deck.new(width: CARD_W, height: CARD_H, cards: n) do
  background color: :white
  text str: data['label'], x: tx(USABLE_X), y: ty(25), width: "#{USABLE_W}mm", height: '30mm',
       font: "#{FONT} bold 20", align: :center, valign: :middle
  text str: '絆抽選カード', x: tx(USABLE_X), y: ty(74), width: "#{USABLE_W}mm", height: '8mm',
       font: "#{FONT} 6.5", align: :center, color: '#555555'
  save_pdf(**pdf_opts('13_love_luck'))
end
puts "love_luck: #{n} cards (no back)"
