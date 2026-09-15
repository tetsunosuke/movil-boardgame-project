#!/usr/bin/env ruby
# encoding: utf-8
# 「テッペン」プロトタイプ用カード印刷データ(Squib版)。自分でA4を切って
# 実際にプレイできるようにするためのもの。塗り足しなし、実寸63×88mm。
#
# 2026-09-14: プレイヤーごとに手札を配って手元に隠し持つ運用になったため、裏面が
# 完全に無地(役職がわからない)である必要が生じた。厚紙+スリーブで裏面を兼ねる方式をやめた。
# 2026-09-15: 最初は表+裏(裏は180度回転)のペアを1枚の紙に配置し山折りで貼り合わせる方式
# (印刷用/_lib/fold_proto_a4.yml)を試したが、1枚の紙に表裏ペアを収める都合上どうしても
# 1カード分の面積を2倍消費してしまい、A4 1枚あたり最大4組(=8枚相当)が幾何学的な上限で、
# 大きな余白が残っても9枚/枚には原理的に到達できないことが判明(63×88mmのカード9枚を
# 敷き詰めるとA4がほぼ埋まるため、その2倍の面積が要るペア形式では4組が上限)。
# そのため「表だけを9枚/枚で敷き詰めたシート」と「裏だけを9枚/枚で敷き詰めたシート」を
# 別々に用意し、あとから同じ種類同士(手下は手下、ナワバリはナワバリ)を1枚ずつ貼り合わせる
# 方式に変更した。裏面は役職によらず完全に同一のデザインなので、表と裏の対応位置を
# 揃える必要はなく(fold式のような境界合わせ不要)、ただ同じ種類の枚数分だけ裏を用意すればよい。
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

# 手下カードの裏(伏せて持つため、番号によらず完全に同一のデザインであることが重要)
def draw_member_back_p(range)
  rect x: tx(3), y: ty(3), width: "#{TRIM_W - 6}mm", height: "#{TRIM_H - 6}mm",
       stroke_color: :black, stroke_width: 1.5, range: range
  text str: 'テッペン', x: tx(USABLE_X), y: ty(TRIM_H / 2 - 8), width: "#{USABLE_W}mm", height: '16mm',
       font: "#{FONT} bold 20", align: :center, valign: :middle, range: range
  text str: '手下', x: tx(USABLE_X), y: ty(TRIM_H / 2 + 8), width: "#{USABLE_W}mm", height: '8mm',
       font: "#{FONT} 9", align: :center, valign: :middle, color: '#737373', range: range
end

# ナワバリカードの裏(共通デザイン)
def draw_turf_back_p(range)
  rect x: tx(3), y: ty(3), width: "#{TRIM_W - 6}mm", height: "#{TRIM_H - 6}mm",
       stroke_color: :black, stroke_width: 1.5, range: range
  text str: 'テッペン', x: tx(USABLE_X), y: ty(TRIM_H / 2 - 8), width: "#{USABLE_W}mm", height: '16mm',
       font: "#{FONT} bold 20", align: :center, valign: :middle, range: range
  text str: 'ナワバリ', x: tx(USABLE_X), y: ty(TRIM_H / 2 + 8), width: "#{USABLE_W}mm", height: '8mm',
       font: "#{FONT} 9", align: :center, valign: :middle, color: '#737373', range: range
end

member_data = Squib.csv file: 'data/member.csv', explode: 'Copies'
turf_data = Squib.csv file: 'data/turf.csv'

member_n = member_data['number'].size
turf_n = turf_data['value'].size
total = member_n + turf_n

member_r = seq_range(0, member_n)
turf_r = seq_range(member_n, turf_n)
member_front_data = pad_data(member_data, total, 0)
turf_front_data = pad_data(turf_data, total, member_n)

# 表だけを隙間なく詰めたシート(型の境界をまたいで9枚/ページ)
Squib::Deck.new(width: CARD_W, height: CARD_H, cards: total) do
  background color: :white, range: :all
  draw_member_front_p(member_front_data, member_r)
  draw_turf_front_p(turf_front_data, turf_r)
  save_pdf(**pdf_opts('teppen_proto_front'))
end

# 裏だけを隙間なく詰めたシート(手下用・ナワバリ用それぞれ同一デザインを枚数分)
Squib::Deck.new(width: CARD_W, height: CARD_H, cards: total) do
  background color: :white, range: :all
  draw_member_back_p(member_r)
  draw_turf_back_p(turf_r)
  save_pdf(**pdf_opts('teppen_proto_back'))
end

puts "proto front deck: #{total} cards (member #{member_n} + turf #{turf_n}), 9枚/A4シート"
puts "proto back deck: #{total} cards (member #{member_n} + turf #{turf_n} ぶんの共通デザイン), 9枚/A4シート"
puts '  組み立て方: 表シートと裏シートをそれぞれ切り出し、同じ種類(手下は手下、ナワバリはナワバリ)' \
     '同士で1枚ずつ貼り合わせる(裏は共通デザインなので特定の表と対応させる必要はない)'
