# encoding: utf-8
# 「キャリア・アイランド」おもて面の共通レイアウト(deck_print.rb / deck_proto.rb 共用)。
# 文字サイズは卓上で読めるよう大きめ(本文10〜12pt、バッジ/ラベル8.5〜9pt)に設定している。
#
# 方針: テキストの高さを Squib の text が返す extents で実測し、そこから各要素のy座標を決める。
#  - 上から: バッジ → タイトル →(お題)の順に積む
#  - 下から: 効果ボックスは内容の高さに合わせて下端固定で伸びる(下端にsetup/bonusがあればその上)
#  - CSVの文言が多少増減しても自動で流れる。重なり・はみ出しの余裕(slack)は
#    LAYOUT_REPORT に溜め、print_layout_report で一覧する(負なら重なっている)。
# 呼び出し側は Squibcommon::Print か Proto を include 済みであること(MARGIN/USABLE_W/TRIM_H/tx/ty)。

SQUIB_DPI = 300.0
LAYOUT_REPORT = []

def px_mm(px) = px.to_f * 25.4 / SQUIB_DPI
def mmv(v) = "#{v.round(3)}mm"

# 共通スタイル(pt)。:center は役職/年代/目標/カードのようにタイトルを中央に置く型。
BASE_STYLE = { badge: 10, icon: 16, name: 15, prompt: 11, label: 9, value: 11.5, foot: 10,
               min_box: 22, center: false, center_value: false }.freeze
FRONT_STYLES = {
  'trouble'  => BASE_STYLE.merge(name: 16, value: 11),
  'life'     => BASE_STYLE.merge(name: 16, value: 11),
  'role'     => BASE_STYLE.merge(center: true, name: 20, value: 11.5, min_box: 26),
  'age'      => BASE_STYLE.merge(center: true, name: 20, value: 11.5, min_box: 26),
  'goal'     => BASE_STYLE.merge(center: true, name: 20, value: 11.5, min_box: 26),
  'token'    => BASE_STYLE.merge(center: true, name: 24, value: 9.5, foot: 9, min_box: 20),
  # マスカードの効果は「マネー+2」などの短い数値の増減なので中央寄せ。※注記と補足(bonus/setup)は左寄せ。
  'labor'    => BASE_STYLE.merge(center_value: true),
  'learning' => BASE_STYLE.merge(center_value: true),
  'leisure'  => BASE_STYLE.merge(center_value: true),
  'love'     => BASE_STYLE.merge(center_value: true),
}.freeze
DILEMMA_STYLE = { badge: 10, name: 16, label: 13, text: 12.5 }.freeze

# 画面外に描いて [幅mm, 高さmm] を測る(空文字/nilは[0,0])。width_mm=nilなら自然幅。
def measure(strs, width_mm, font, range)
  o = { str: strs, x: '-2000mm', y: '-2000mm', font: font, range: range, ellipsize: :none }
  o[:width] = mmv(width_mm) if width_mm
  ext = text(**o)
  strs.each_index.map do |i|
    e = ext[i]
    e && !strs[i].to_s.empty? ? [px_mm(e[:width]), px_mm(e[:height])] : [0.0, 0.0]
  end
end

# ---- 手動の折り返し(表示上の改行のみ。CSVの文言は変えない) ----
# Pangoの自動折り返しは「+1」「う。」だけが次行に残ることがあるため、1行が幅を超える場合に限り、
# 禁則(行頭に来てはいけない文字/行末に来てはいけない文字/英数字の途中)を避けて均等に割る。
NO_LINE_START = '、。，．）)」』・％%+-ー!?！？:：'.chars.freeze
NO_LINE_END = '(（「『'.chars.freeze

def hira?(c) = c.between?('ぁ', 'ゟ')
def kata?(c) = c.between?('゠', 'ヿ')
def kanji?(c) = c.between?('一', '鿿')

def char_w(c) = c.ord < 128 ? 0.55 : 1.0

def break_ok?(prev, nxt)
  return false if NO_LINE_START.include?(nxt) || NO_LINE_END.include?(prev)
  return false if prev.ord < 128 && nxt.ord < 128
  return false if (prev == '・' && nxt.ord < 128) || (nxt == '・' && prev.ord < 128)   # 「第1・4・7・10」
  true
end

# 自然幅 nat_mm の1行を、幅 avail_mm に収まる最少行数・均等な行長で割る(動的計画法)。
# 幅は文字種ごとの概算(char_w)で見積もり、割った後に fit(実測lambda)で検証して、
# 収まらなければ許容幅を狭めて再試行する。
def balanced_break(line, nat_mm, avail_mm, em_mm, fit)
  return line if line.chars.size < 2
  chars = line.chars
  [0.97, 0.92, 0.86, 0.80].each do |factor|
    cand = balanced_break_dp(chars, avail_mm * factor / em_mm)
    return cand if cand.split("\n").all? { |l| fit.call(l) <= avail_mm }
  end
  balanced_break_dp(chars, avail_mm * 0.75 / em_mm)
end

def balanced_break_dp(chars, limit_em)
  len = chars.size
  cum = [0.0]
  chars.each { |c| cum << cum.last + char_w(c) }
  total = cum.last
  n_min = (total / limit_em).ceil
  inf = Float::INFINITY
  results = []
  (n_min..n_min + 3).each do |n|
    break if results.size >= 2
    ideal = total / n
    # dp[j][b] = j行で先頭b文字を使う最小コスト
    dp = Array.new(n + 1) { Array.new(len + 1, inf) }
    from = Array.new(n + 1) { Array.new(len + 1) }
    dp[0][0] = 0.0
    (1..n).each do |j|
      (1..len).each do |b|
        next unless b == len || break_ok?(chars[b - 1], chars[b])
        (0...b).each do |a|
          next if dp[j - 1][a] == inf
          wl = cum[b] - cum[a]
          next if wl > limit_em
          bonus = 0.0
          if b < len
            p0 = chars[b - 1]
            n0 = chars[b]
            bonus += 3.0 if '、。'.include?(p0) || '（('.include?(n0) || '）)'.include?(p0)
            bonus += 2.5 if hira?(p0) && !hira?(n0)            # 「…を|1枚」のような文節の切れ目
            bonus -= 2.0 if hira?(n0) && !'、。'.include?(p0)   # 「引い|て」のように活用語尾の前で切らない
            bonus -= 2.0 if (kata?(p0) && kata?(n0)) || (kanji?(p0) && kanji?(n0))  # 語の途中は避ける
            bonus = [bonus, 2.5].min
          end
          c = dp[j - 1][a] + 0.4 * (wl - ideal)**2 - bonus
          if c < dp[j][b]
            dp[j][b] = c
            from[j][b] = a
          end
        end
      end
    end
    next if dp[n][len] == inf
    cuts = []
    b = len
    n.downto(1) { |j| a = from[j][b]; cuts << a if a > 0; b = a }
    out = +''
    chars.each_with_index { |c, k| out << "\n" if cuts.include?(k); out << c }
    results << [dp[n][len] + 6.0 * n, out]   # 行数が増えるほど少しだけ不利に
  end
  results.empty? ? chars.join : results.min_by(&:first).last
end

def natural_width_mm(str, font, probe)
  ext = text(str: Array.new(size, str), x: '-2000mm', y: '-2000mm', font: font, range: [probe], ellipsize: :none)
  px_mm(ext[probe][:width])
end

# strs(カード番号空間)の各行が width_mm を超える場合だけ balanced_break する。
def soft_wrap(strs, width_mm, font, range)
  probe = range.first
  em_mm = font.split.last.to_f * 25.4 / 72.0
  strs.map do |s|
    next s if s.to_s.empty?
    s.split("\n", -1).map do |line|
      nat = natural_width_mm(line, font, probe)
      nat > width_mm ? balanced_break(line, nat, width_mm, em_mm, ->(l) { natural_width_mm(l, font, probe) }) : line
    end.join("\n")
  end
end

def draw_badge(badge, size, range, min_w = 0)
  bh = 6.5
  bm = measure(badge, nil, "#{FONT} bold #{size}", range)
  bw = bm.map { |wh| [wh[0] + 6.0, min_w].max }
  rect x: tx(MARGIN), y: ty(MARGIN), width: bw.map { |v| mmv(v) }, height: mmv(bh),
       stroke_color: :black, stroke_width: 1, range: range
  text str: badge, x: tx(MARGIN), y: ty(MARGIN), width: bw.map { |v| mmv(v) }, height: mmv(bh),
       font: "#{FONT} bold #{size}", align: :center, valign: :middle, range: range
  MARGIN + bh
end

# trouble/life/role/age/goal/token/labor/learning/leisure/love 共通のおもて面。
# ilv: データ列(長さn)をカード番号空間の配列へ変換するlambda(入稿用=表裏交互、試作=恒等)。
def draw_front(ctype, data, range, ilv)
  st = FRONT_STYLES.fetch(ctype)
  col = ->(k) { ilv.call(data[k]) }
  w = USABLE_W
  bot = TRIM_H - 4.5
  badge = col.('badge'); icon = col.('icon'); name = col.('name'); prompt = col.('prompt')
  elabel = col.('effect_label'); evalue = col.('effect_value')
  foot = col.('bonus').zip(col.('setup')).map { |b, s| [b, s].reject { |x| x.to_s.empty? }.join("\n") }
  size = name.size

  badge_bottom = draw_badge(badge, st[:badge], range)
  text str: icon, x: tx(MARGIN + w - 20), y: ty(MARGIN), width: '20mm', height: mmv(6.5),
       font: "#{FONT} #{st[:icon]}", align: :right, valign: :middle, range: range

  nfont = "#{FONT} bold #{st[:name]}"
  pfont = "#{FONT} #{st[:prompt]}"
  lfont = "#{FONT} bold #{st[:label]}"
  vfont = "#{FONT} bold #{st[:value]}"
  ffont = "#{FONT} #{st[:foot]}"
  name = soft_wrap(name, w, nfont, range)
  prompt = soft_wrap(prompt, w, pfont, range)
  # center_valueの型では、「※」で始まる注記行だけを分けて左寄せで描く(中央寄せだと読みにくいため)。
  split_val = lambda do |keep_note|
    evalue.map do |v|
      next v if v.to_s.empty?
      lines = v.split("
", -1)
      lines = lines.select { |l| l.start_with?('※') == keep_note } if st[:center_value]
      next '' if !st[:center_value] && keep_note
      lines.join("
")
    end
  end
  evmain = soft_wrap(split_val.call(false), w - 3, vfont, range)
  evnote = soft_wrap(split_val.call(true), w - 3, ffont, range)
  foot = soft_wrap(foot, w, ffont, range)
  hn = measure(name, w, nfont, range).map(&:last)
  hp = measure(prompt, w, pfont, range).map(&:last)
  hl = measure(elabel, w - 2, lfont, range).map(&:last)
  hvm = measure(evmain, w - 3, vfont, range).map(&:last)
  hvn = measure(evnote, w - 3, ffont, range).map(&:last)
  hv = (0...size).map { |i| hvm[i] + (hvn[i] > 0 ? 1.2 + hvn[i] : 0.0) }
  hf = measure(foot, w, ffont, range).map(&:last)

  ny = badge_bottom + 3.0
  geo = (0...size).map do |i|
    foot_y = bot - hf[i]
    box_bottom = hf[i] > 0 ? foot_y - 2.5 : bot
    has_box = !elabel[i].to_s.empty?
    has_val = hv[i] > 0
    hdr = has_box ? 1.6 + hl[i] : 0.0
    box_h = (has_box || has_val) ? [st[:min_box], hdr + 1.5 + hv[i] + 2.0].max : 0.0
    box_top = box_bottom - box_h
    avail_top = box_top + hdr + 1.5
    avail_bot = box_bottom - 1.5
    vy = avail_top + [(avail_bot - avail_top - hv[i]) / 2.0, 0.0].max
    g = { note_y: vy + hvm[i] + 1.2, foot_y: foot_y, box_top: box_top, box_h: box_h, has_box: has_box, label_y: box_top + 1.6, vy: vy }
    if st[:center]
      region = [box_top - 3.0 - ny, 0.0].max
      g[:name_h] = region
      g[:slack] = region - hn[i]
    else
      g[:py] = ny + hn[i] + 2.5
      content_bottom = prompt[i].to_s.empty? ? ny + hn[i] : g[:py] + hp[i]
      g[:slack] = box_top - content_bottom
    end
    LAYOUT_REPORT << [ctype, i, name[i].to_s.tr("\n", ' '), g[:slack]] if range.include?(i)
    g
  end

  g = ->(k) { geo.map { |x| mmv(x[k] || 0) } }

  if st[:center]
    text str: name, x: tx(MARGIN), y: ty(ny), width: mmv(w), height: g.(:name_h),
         font: nfont, align: :center, valign: :middle, ellipsize: :none, range: range
  else
    text str: name, x: tx(MARGIN), y: ty(ny), width: mmv(w), font: nfont, ellipsize: :none, range: range
    text str: prompt, x: tx(MARGIN), y: geo.map { |x| ty(x[:py]) }, width: mmv(w),
         font: pfont, color: '#444444', ellipsize: :none, range: range
  end
  rect x: tx(MARGIN), y: geo.map { |x| ty(x[:box_top]) }, width: mmv(w), height: g.(:box_h),
       stroke_color: geo.map { |x| x[:has_box] ? :black : '#0000' }, stroke_width: 1.2, range: range
  text str: elabel, x: tx(MARGIN + 1), y: geo.map { |x| ty(x[:label_y]) }, width: mmv(w - 2),
       font: lfont, align: :center, color: '#444444', ellipsize: :none, range: range
  text str: evmain, x: tx(MARGIN + 1.5), y: geo.map { |x| ty(x[:vy]) }, width: mmv(w - 3),
       font: vfont, align: st[:center_value] ? :center : :left, ellipsize: :none, range: range
  text str: evnote, x: tx(MARGIN + 1.5), y: geo.map { |x| ty(x[:note_y]) }, width: mmv(w - 3),
       font: ffont, align: :left, color: '#333333', ellipsize: :none, range: range
  text str: foot, x: tx(MARGIN), y: geo.map { |x| ty(x[:foot_y]) }, width: mmv(w),
       font: ffont, align: :left, color: '#333333', ellipsize: :none, range: range
end

# ジレンマ(専用レイアウト): タイトル → A案(ラベル+本文) → B案 を上から積む。
def draw_dilemma_front(data, range, ilv)
  st = DILEMMA_STYLE
  col = ->(k) { ilv.call(data[k]) }
  w = USABLE_W
  bot = TRIM_H - 4.5
  name = col.('name'); al = col.('opt_a_label'); at = col.('opt_a_text')
  bl = col.('opt_b_label'); bt = col.('opt_b_text')

  badge_bottom = draw_badge(col.('badge'), st[:badge], range)
  nfont = "#{FONT} bold #{st[:name]}"
  lfont = "#{FONT} bold #{st[:label]}"
  tfont = "#{FONT} #{st[:text]}"
  name = soft_wrap(name, w, nfont, range)
  at = soft_wrap(at, w, tfont, range)
  bt = soft_wrap(bt, w, tfont, range)
  hn = measure(name, w, nfont, range).map(&:last)
  hal = measure(al, w, lfont, range).map(&:last)
  hat = measure(at, w, tfont, range).map(&:last)
  hbl = measure(bl, w, lfont, range).map(&:last)
  hbt = measure(bt, w, tfont, range).map(&:last)

  ny = badge_bottom + 3.0
  geo = (0...name.size).map do |i|
    aly = ny + hn[i] + 3.5
    aty = aly + hal[i] + 1.0
    bly = aty + hat[i] + 5.0
    bty = bly + hbl[i] + 1.0
    LAYOUT_REPORT << ['dilemma', i, name[i].to_s, bot - (bty + hbt[i])] if range.include?(i)
    { aly: aly, aty: aty, bly: bly, bty: bty }
  end

  text str: name, x: tx(MARGIN), y: ty(ny), width: mmv(w), font: nfont, ellipsize: :none, range: range
  { 'aly' => [al, lfont], 'aty' => [at, tfont], 'bly' => [bl, lfont], 'bty' => [bt, tfont] }.each do |k, (str, font)|
    text str: str, x: tx(MARGIN), y: geo.map { |x| ty(x[k.to_sym]) }, width: mmv(w), font: font, ellipsize: :none, range: range
  end
end

def print_layout_report
  puts '--- layout slack (mm, 小さいほどタイト / 負なら重なり) ---'
  LAYOUT_REPORT.group_by(&:first).each do |ctype, rows|
    worst = rows.min_by { |r| r[3] }
    flag = worst[3] < 0 ? '  !!! OVERLAP' : ''
    puts format('  %-9s min slack %6.1f  (card %d: %s)%s', ctype, worst[3], worst[1], worst[2][0, 24], flag)
  end
end
