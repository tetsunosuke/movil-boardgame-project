# encoding: utf-8
# movil-boardgame-project 全ゲーム共通のSquibヘルパー。
# 印刷仕様(仕上がり・塗り足し・セーフティ)の詳細は memory: movil_boardgame_print_card_spec 参照。
#
# 使い方:
#   require_relative '../_lib/squib_common'
#   include Squibcommon::Print   # 入稿用(59×86mm+3mm塗り足し)
#   include Squibcommon::Proto   # プロトタイプ用(63×88mm、塗り足しなし)
require 'squib'

module Squibcommon
  # 入稿用(gr@phicトレーディングカード小 想定): 仕上がりW59×H86mm、塗り足し3mm
  module Print
    BLEED = 3.0
    TRIM_W = 59.0
    TRIM_H = 86.0
    MARGIN = 3.5
    CARD_W = "#{TRIM_W + 2 * BLEED}mm"
    CARD_H = "#{TRIM_H + 2 * BLEED}mm"
    USABLE_W = TRIM_W - 2 * MARGIN
    USABLE_X = MARGIN

    def tx(mm) = "#{mm + BLEED}mm"
    def ty(mm) = "#{mm + BLEED}mm"

    def pdf_opts(name)
      { file: "#{name}.pdf", crop_marks: true, trim: "#{BLEED}mm",
        width: '210mm', height: '297mm', margin: '8mm', gap: '3mm' }
    end
  end

  # プロトタイプ用: 実寸63×88mm(標準スリーブサイズ)、塗り足しなし、A4最大枚数
  module Proto
    BLEED = 0.0
    TRIM_W = 63.0
    TRIM_H = 88.0
    MARGIN = 3.5
    CARD_W = "#{TRIM_W}mm"
    CARD_H = "#{TRIM_H}mm"
    USABLE_W = TRIM_W - 2 * MARGIN
    USABLE_X = MARGIN

    def tx(mm) = "#{mm}mm"
    def ty(mm) = "#{mm}mm"

    def cut_guide
      rect x: 0, y: 0, width: CARD_W, height: CARD_H, stroke_color: '#aaaaaa', stroke_width: 0.75
    end

    def pdf_opts(name)
      { file: "#{name}.pdf",
        width: '210mm', height: '297mm', margin: '5mm', gap: '2mm' }
    end
  end

  # front_arr(長さn)とback_arr(長さnまたは単一値)を [front0,back0,front1,back1,...] の順に
  # 交互配置した長さ2nの配列を作る(入稿用の「表→裏が隣接」レイアウトのため)。
  def interleave(front_arr, back_arr)
    n = (front_arr.is_a?(Array) ? front_arr : back_arr).size
    front_arr = Array.new(n, front_arr) unless front_arr.is_a?(Array)
    back_arr = Array.new(n, back_arr) unless back_arr.is_a?(Array)
    Array.new(n * 2) { |i| i.even? ? front_arr[i / 2] : back_arr[i / 2] }
  end

  def front_range(n) = (0...(n * 2)).step(2).to_a
  def back_range(n) = (1...(n * 2)).step(2).to_a

  # プロトタイプ用: 複数の型(トラブル/役職/…)を1つの連続したデッキにまとめて
  # A4 1枚=9枚のグリッドを型の境界をまたいで隙間なく詰めるためのヘルパー。
  # arrをtotal長の配列に投影し、offset..offset+arr.size-1の位置にだけ値を置く
  # (それ以外はnilで埋めるが、range:で該当オフセットのみ描画するため実害はない)。
  def project(arr, total, offset)
    out = Array.new(total)
    arr.each_with_index { |v, j| out[offset + j] = v }
    out
  end

  # Squib.csvが返すデータハッシュの全カラムをproject()で投影したコピーを返す。
  def pad_data(data, total, offset)
    out = {}
    data.each { |k, v| out[k] = project(v, total, offset) }
    out
  end

  def seq_range(offset, n) = (offset...(offset + n)).to_a
end
