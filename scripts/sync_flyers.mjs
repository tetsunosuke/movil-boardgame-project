import { copyFileSync, statSync, existsSync } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

// flyers/ は GitHub Pages (deploy-flyers.yml) の公開元。各ゲームのリポジトリ直下や
// 印刷用/<game>/_output に生成された最新の成果物を、公開用にflyers/へコピーするだけの
// スクリプト。flyers/配下のファイルを直接手編集しないこと(次にこれを実行すると上書きされる)。
//
// 実行前提: 各ゲームの gen_rulebook_pdf.mjs / gen_rulebook_docx.mjs / gen_flyer_docx.mjs /
// gen_cards_pdf.mjs 等を先に実行し、コピー元(下記SYNC_MAP左辺)が最新化されていること。
//
// 命名規則: 各ゲームのリポジトリ内では RULEBOOK.md/.pdf/.docx と FLYER.docx/.pdf に統一
// (4ゲーム共通)。flyers/は複数ゲームのファイルが同じ階層に並ぶ共有フォルダなので、
// コピー先だけ <ゲームslug>-rulebook.* / <ゲームslug>-flyer.* のように名前を振り直す。
// 各ゲームに元々あった「デザイン版」の成果物(teppenの折りたたみ版、ai-parrotの装飾マニュアル、
// my-ability-rankingの_v8一式)はこのRULEBOOK/FLYERパイプラインの対象外なので、
// 元の名前のまま個別にコピーしている。
const root = path.dirname(fileURLToPath(import.meta.url));
const project = path.resolve(root, '..');

const SYNC_MAP = [
  // --- career-island ---
  ['career-island/RULEBOOK.pdf', 'flyers/career-island-rulebook.pdf'],
  ['career-island/RULEBOOK.html', 'flyers/career-island-rulebook.html'],
  ['career-island/career-island-cards.html', 'flyers/career-island-cards.html'],
  ['career-island/career-island-cards.pdf', 'flyers/career-island-cards.pdf'],
  ['career-island/FLYER.pdf', 'flyers/career-island-flyer.pdf'],

  // --- teppen ---
  ['teppen/teppen-rulebook-a4.html', 'flyers/teppen-rulebook-a4.html'],
  ['teppen/teppen-rulebook-a4.pdf', 'flyers/teppen-rulebook-a4.pdf'],
  ['teppen/RULEBOOK.pdf', 'flyers/teppen-rulebook.pdf'],
  ['teppen/teppen-cards.pdf', 'flyers/teppen-cards.pdf'],
  ['teppen/FLYER.pdf', 'flyers/teppen-flyer.pdf'],

  // --- ai-parrot ---
  ['ai-parrot/ai-parrot-manual.html', 'flyers/ai-parrot-manual.html'],
  ['ai-parrot/ai-parrot-manual.pdf', 'flyers/ai-parrot-manual.pdf'],
  ['ai-parrot/RULEBOOK.pdf', 'flyers/ai-parrot-rulebook.pdf'],
  ['ai-parrot/ai-parrot-cards.pdf', 'flyers/ai-parrot-cards.pdf'],
  ['ai-parrot/ai-parrot-cards-proto.pdf', 'flyers/ai-parrot-cards-proto.pdf'],
  ['ai-parrot/FLYER.pdf', 'flyers/ai-parrot-flyer.pdf'],

  // --- my-ability-ranking (slug: ability-ranking) ---
  ['my-ability-ranking/私の能力ランキング_ルール説明書_v8.pdf', 'flyers/私の能力ランキング_ルール説明書_v8.pdf'],
  ['my-ability-ranking/RULEBOOK.pdf', 'flyers/ability-ranking-rulebook.pdf'],
  ['my-ability-ranking/私の能力ランキング_配布用マニュアル_v8.pdf', 'flyers/私の能力ランキング_配布用マニュアル_v8.pdf'],
  ['my-ability-ranking/私の能力ランキング_能力一覧表_v8.pdf', 'flyers/私の能力ランキング_能力一覧表_v8.pdf'],
  ['my-ability-ranking/私の能力ランキング_カード印刷データ_v8.pdf', 'flyers/私の能力ランキング_カード印刷データ_v8.pdf'],
  ['my-ability-ranking/FLYER.pdf', 'flyers/ability-ranking-flyer.pdf'],
];

let copied = 0;
let skipped = 0;
for (const [src, dest] of SYNC_MAP) {
  const srcPath = path.join(project, src);
  const destPath = path.join(project, dest);
  if (!existsSync(srcPath)) {
    console.warn('SKIP (source not found):', src);
    skipped += 1;
    continue;
  }
  copyFileSync(srcPath, destPath);
  const { size } = statSync(destPath);
  console.log(`synced: ${dest} (${size} bytes)`);
  copied += 1;
}
console.log(`\ndone: ${copied} synced, ${skipped} skipped`);
