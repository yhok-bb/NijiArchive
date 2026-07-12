---
name: roadmap-step
description: Use when starting a NijiArchive roadmap Step, resuming work without a clear scope, or judging whether a Step is complete. Triggers: 「Step Xを始める」「次のStepに進みたい」「このStep終わった？」「今どこまでやった？」
---

# Roadmap Step

## Overview

NijiArchiveはStep単位（Part 3参照）で進める。このスキルの目的は2つ：**着手時にスコープを固定する**こと、**完了基準を検証せずに完了と言わない**こと。

## 着手時

1. `design/nijiarchive_roadmap_part3_implementation_operations.md` の該当Stepセクションを読む
2. 以下を冒頭で提示する：
   - **実装タスク一覧**（roadmapの表をそのまま使う）
   - **設計判断ポイント**（各タスクに付記されているもの。実装中にここへ来たら `/adr` を検討）
   - **完了基準**（このStepのゴール。曖昧なら着手前に具体化する）
   - **このStepに含まれないもの**（隣接Stepの機能を1行で明示。スコープ肥大化の防波堤）
3. タスクをTODOに落としてから実装に入る

## 完了判定時

完了基準を1つずつ、**実際に動かして**確認する。roadmapの完了基準は観察可能な事実で書かれている（例：「複数解像度の切り替えが動く」「秒間100コメントでも落ちない」）。

| 判定 | 条件 |
|------|------|
| 完了 | 全基準を検証済み。検証方法と結果を報告に含める |
| 未完了 | 1つでも未検証・未達成。何が残っているかを列挙する |

完了したら次の2つを促す（やるかはユーザー判断）：
- 設計判断ポイントで下した判断の `/adr` 記録
- `/step-article` での記事下書き（Part 3 の記事化戦略に候補タイトルあり）

## Red Flags

- 「完了基準の検証は今回スキップ」→ 未完了。roadmapは「完了基準は妥協せず、曖昧なまま次に進まない」と明記している
- 「ついでに次のStepの機能も」→ スコープ肥大化。このプロジェクト最大の中断リスク
- 「たぶん動くはず」→ 動かして確かめるまで完了と言わない
