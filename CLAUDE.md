# NijiArchive

学習目的の個人開発。二層構造のサービス：
表は「虹ヶ咲ライブのアーカイブ・関連動画ファンポータル」（軸1）、
裏は「配信技術の中身（ビットレート推移・ABR切替・CDNキャッシュ・視聴統計）が覗ける可視化ダッシュボード」（軸2）。
両軸は独立機能ではなく、同じ配信基盤の見せ方が違うだけ、という設計。

詳細は roadmap 4部作を参照（このリポジトリの一次資料）：

- `design/nijiarchive_roadmap_part1_concept_requirements.md` — コンセプト・FR/NFR・ペルソナ・ユースケース
- `design/nijiarchive_roadmap_part2_architecture_design.md` — アーキテクチャ・ER図・API/チャンネル設計
- `design/nijiarchive_roadmap_part3_implementation_operations.md` — Step一覧・各Stepの完了基準・記事化戦略
- `design/nijiarchive_roadmap_part4_learning_tracks.md` — 深掘りフェーズ（OSS読解・置き換え実装・計測）の定義とStepへの配分

## 現在地（2026-07時点）

Step 1（HLS配信MVP）に着手中。Rails 8雛形＋開発用PostgreSQL（compose.yaml、ホスト側5433番）まで構築済み。
Step -2〜-1は後回しにして実装から入る方針に変更（Step 1の設計メモは `design/my-design.md`）。
Stepに着手するときは、必ず Part 3 の該当Stepの「実装タスク」「設計判断ポイント」「完了基準」を最初に読む（`/roadmap-step` を使う）。

## 技術スタック（確定済み・変更は相談）

Rails 8 / Action Cable / Solid Queue / Solid Cache / PostgreSQL（+pgvector）/ Kamal 2 / Cloudflare R2 + CDN / FFmpeg / hls.js / OpenTelemetry + Grafana Cloud / YouTube Data API v3

- **Redisは使わない**（Solid Queue/Cacheで代替。Rails 8標準構成の学習が目的）
- **認証はRails 8 Authentication Generator。Deviseは使わない**（内部実装を理解した上で使う学習目的＋要件に対してオーバースペック）

## 設計原則（roadmapで確定済み。破る変更は先に一言）

1. **軸2は読み取り専用の可視化レイヤー**。軸1（視聴体験）のコアロジックに影響を与えない。ダッシュボードが死んでも動画再生は継続する（責務分離が設計上の必須要件）
2. **データ整合性の判断軸は「表示用かトリガーか」**：表示用データはAP寄り（Comments・ViewerStats）、可否判断のトリガーはCP寄り（Sessions）。新しいデータを扱うときもこの軸で判断し、理由をADRに残す
3. **クライアント→サーバーの計測イベントは必ずサンプリング**（例：5秒に1回）。可視化のために配信本体のパフォーマンスを犠牲にしない
4. **YouTube動画本体の再配信はしない**。メタデータ・埋め込み・リンクのみ。API呼び出しはSolid Queueの定期ジョブでバッチ処理（リアルタイムに叩かない）。APIキーはRails Credentials管理
5. **Out of Scopeに踏み込まない**：マネタイズ・決済・複数グループ展開・ネイティブアプリ化はMVPに含めない

## 開発の進め方

- **Issue駆動で進める**。実装に着手する前に必ずGitHub issue（yhok-bb/NijiArchive）を切り、issue番号なしのコミットで機能を作らない。1 issue＝0.5〜3日で閉じられるスライス粒度で、本文に完了条件と必須テストを書く。設計上の未決事項は「関所」としてチェックリストで残す
- **issueは着手直前に切る**（just-in-time）。Step単位で入るときに細分化し、先のStepのissueを一括で先切りしない（前提が変わって腐るため）
- **機能ごとにPRを作る**。機能実装はブランチを切ってPR経由でマージし、mainに直接コミットしない（ドキュメント・設定の微修正は例外可）。PRは `Closes #<issue番号>` でissueに紐づけ、CIが緑になってからマージする
- **Step単位で進める**。完了基準を満たすまで次のStepに進まない。「ついでに次の機能も」はスコープ肥大化（このプロジェクト最大のリスク）
- **完了宣言の前に完了基準を検証する**。完了基準は数値・観察可能な事実で書かれている（例：「ApacheBenchで秒間100コメントでも落ちない」）ので、実際に確かめる
- **設計判断は `docs/adr/` に記録する**（`/adr`）。「面接でなぜこの設計かを一貫して説明できること」がプロジェクトの成功基準の一つ
- **Step完了ごとに記事化する**（`/step-article`）。記事候補タイトルは Part 3 の記事化戦略の表にある
- **コスト制約：月数千円以内**。インフラ・外部サービスの選択肢を出すときは月額コストを添える

## プロジェクトスキル

- `/roadmap-step` — Stepの着手・完了判定
- `/adr` — 設計判断の記録
- `/step-article` — Step完了後の記事下書き
