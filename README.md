# movil-boardgame-project

アナログ(物理)ボードゲームとして発表することを最終目標にした、4つのゲームのプロジェクト一式です。
それぞれ独立したリポジトリとして開発していますが、印刷パイプラインと配布物の運用方針は共通です。

## ゲーム一覧

| ディレクトリ | タイトル | 概要 |
|---|---|---|
| `career-island/` | キャリア・アイランド | 協力型シリアスゲーム。Web版(Astro+React、1人プレイ+AI NPC)あり |
| `teppen/` | テッペン | 不良チーム抗争の心理戦カードゲーム。Web版なし、印刷資料のみ |
| `ai-parrot/` | プロンプト・スパイ 〜AIオウムと秘密の暗号〜 | AIへの話しかけ方を学ぶ対話カードゲーム。Web版(Astro+Gemini API)あり |
| `my-ability-ranking/` | 私の能力ランキング | 自己評価と他者予想のギャップを扱う対話カードゲーム。Web版なし、Python製印刷パイプライン |

## 各ゲームリポジトリの共通ファイル構成

4ゲームすべて、ルール文書とチラシの原本・生成物を同じ名前・同じ場所に置いています。

```
<game>/
├── RULEBOOK.md      ← ルール文の唯一の原本(人力編集はここだけ)
├── RULEBOOK.html    ← 生成過程の中間ファイル(.gitignore対象)
├── RULEBOOK.pdf     ← ↑から自動生成される配布用ルールブック(PDF)
├── RULEBOOK.docx    ← ↑から自動生成される配布用ルールブック(Word)
├── FLYER.docx       ← 当日配布用チラシの原本(Word。マーケティング的な要約文なので手編集)
├── FLYER.pdf        ← ↑をPDF化したもの
└── scripts/
    ├── gen_rulebook_pdf.mjs   RULEBOOK.md → RULEBOOK.html/.pdf
    ├── gen_rulebook_docx.mjs  RULEBOOK.md → RULEBOOK.docx
    ├── gen_flyer_docx.mjs     FLYER.docx を生成(内容はスクリプト内にハードコード)
    └── assets/qr_*.png        チラシに埋め込むQRコード画像
```

生成コマンド(各ゲームのディレクトリ内で):

```bash
npx tsx scripts/gen_rulebook_pdf.mjs
npx tsx scripts/gen_rulebook_docx.mjs
npx tsx scripts/gen_flyer_docx.mjs
# FLYER.docx → FLYER.pdf はMicrosoft Word(COM)で変換
```

各ゲームには上記に加えて、元々あった「デザイン版」の成果物(teppenの折りたたみ版ルールブック、
ai-parrotの装飾マニュアル、my-ability-rankingの`_v8`一式など)も別名のまま残っています。これらは
このRULEBOOK/FLYERパイプラインの対象外で、それぞれ個別の生成手段(Ruby/Python/手作りHTML)を
持っています。

## `印刷用/` — カード印刷パイプライン

物理カードが必要なゲーム(career-island・teppen・my-ability-ranking)のカードCSV・差し込み画像・
Ruby(Squib)/Pythonの生成スクリプトを格納しています。ゲームごとに`印刷用/<game>/`以下にまとまっており、
`_output/`に生成済みPDFが入ります。

## `flyers/` — 本番公開サイト(GitHub Pages)

**`main`ブランチにpushすると`.github/workflows/deploy-flyers.yml`によって自動的にGitHub Pagesとして
公開される本番ディレクトリです。** 4ゲーム分のルールブック・カード印刷データ・チラシのPDF/HTMLを
1つの階層に集約し、`index.html`から一覧できるようにしています。

`flyers/`配下のファイルは直接手編集しないでください。各ゲーム側(`RULEBOOK.pdf`や`FLYER.pdf`など)を
更新したら、必ず以下のスクリプトで同期します。

```bash
node scripts/sync_flyers.mjs
```

このスクリプトは各ゲームの生成済みファイルを`flyers/`へコピーするだけです。コピー先のファイル名だけ
`<game-slug>-rulebook.pdf`のようにゲーム名を付けて区別しています(4ゲーム分が同じ階層に並ぶため)。

## 変更を公開サイトに反映する手順

1. 該当ゲームで`RULEBOOK.md`または`FLYER.docx`を編集する。
2. そのゲームのディレクトリで生成スクリプトを実行し、PDF/Wordを更新する。
3. プロジェクトルートで`node scripts/sync_flyers.mjs`を実行し、`flyers/`を最新化する。
4. `flyers/index.html`をブラウザで開いて見た目を確認する。
5. 問題なければコミットし、`main`にpushする(**pushした時点で公開サイトに反映されます**)。
