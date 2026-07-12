---
name: step-article
description: Use when a NijiArchive roadmap Step is complete and it's time to draft the tech article, or when the user wants to write up finished work. Triggers: 「記事化して」「記事の下書き」「Zennに書きたい」「Step終わったから記事」
---

# Step記事の下書き

## Overview

Step完了ごとの記事化はこのプロジェクトのモチベーション維持策であり成功基準（記事5本以上）。roadmapは「記事化は後回しにせず、Stepが終わるたびに書く」と定めている。下書きは `docs/articles/` に保存する（Zenn投稿用の素材）。

## 手順

1. `design/nijiarchive_roadmap_part3_implementation_operations.md` の「記事化戦略」の表から該当Stepの候補タイトルを確認する
2. 素材を集める：該当Stepの `docs/adr/` の記録、完了基準の検証結果（数値）、実装中に詰まった点
3. `docs/articles/<step>-<スラッグ>.md` に下書きを作成する

## 記事の構成

```markdown
# <タイトル：記事化戦略の候補をベースに>

## 結論（何を作り、何が分かったか。3行以内）

## 背景（なぜこれを作るのか。二軸コンセプトに触れる）

## 設計判断とトレードオフ（記事の本体。ADRを文章化する）

## 実装の要点（コード断片は最小限、判断が見える箇所だけ）

## 計測結果（完了基準の検証で得た数値。例：CDNキャッシュHIT率、秒間コメント数）

## 振り返り（次にやるなら何を変えるか）
```

## Common Mistakes

- チュートリアル調（手順の羅列）になる → 読者が知りたいのは手順ではなく判断。「なぜそうしたか」を主役にする
- 数値なしで公開する → 「動きました」より「HIT率92%でした」。完了基準の検証結果をそのまま使う
- 完璧を目指して寝かせる → 下書き完成をStepの締めとし、推敲は投稿時にやる
