# NijiArchive

[![CI](https://github.com/yhok-bb/NijiArchive/actions/workflows/ci.yml/badge.svg)](https://github.com/yhok-bb/NijiArchive/actions/workflows/ci.yml)

虹ヶ咲ライブのアーカイブ・関連動画ファンポータル——の皮をかぶった、**配信技術の中身が覗ける可視化ダッシュボード**。

表向きはライブアーカイブのHLS視聴・リアルタイムコメント・関連動画をまとめるファンサイトとして動きます。その裏では、いま自分が見ている配信のビットレート推移・ABR切り替え・CDNキャッシュ状態・全視聴者の視聴統計がリアルタイムで覗けます。両者は独立した機能ではなく、**同じ配信基盤の「見せ方」が違うだけ**という設計です。

| 軸 | 対象 | 提供するもの |
|----|------|------------|
| 軸1（表）：ファンポータル | ファン・一般視聴者 | HLSアーカイブ視聴、リアルタイムコメント、盛り上がり自動検出、YouTube関連動画の集約 |
| 軸2（裏）：可視化ダッシュボード | エンジニア | ビットレート推移、ABR切り替えログ、CDNキャッシュHIT/MISS、視聴ビットレート分布の集計 |

学習目的の個人開発です。「配信システムの仕組みを、動くもので腹落ちして理解する」ことと、その過程の設計判断をすべて説明可能な形で残すことを目的にしています。

## アーキテクチャ概要

```
[管理者] → MP4アップロード → [Rails 8 / Solid Queue] → FFmpegでHLS変換
                                      → [Cloudflare R2 + CDN] → [ブラウザ / hls.js]
                                             ↑
[視聴者] ⇄ Action Cable（コメント・視聴者数・可視化ダッシュボード）
```

設計上の必須要件：軸2のダッシュボードは**読み取り専用の可視化レイヤー**であり、ダッシュボードが死んでも動画再生は継続します。詳細は [design/nijiarchive_roadmap_part2_architecture_design.md](design/nijiarchive_roadmap_part2_architecture_design.md) を参照。

## 技術スタック

| レイヤー | 技術 |
|---------|------|
| バックエンド | Rails 8（Solid Queue / Solid Cache / Solid Cable） |
| リアルタイム通信 | Action Cable |
| DB | PostgreSQL（+pgvector） |
| 動画変換・配信 | FFmpeg / HLS / hls.js |
| ストレージ・CDN | Cloudflare R2 + CDN |
| デプロイ | Kamal 2 |
| 可観測性 | OpenTelemetry + Grafana Cloud |
| 外部API | YouTube Data API v3 |

Redisは使いません（Solid Queue/Cache/CableによるRails 8標準構成の学習が目的）。認証もDeviseではなくRails 8 Authentication Generatorを使います。選定理由の詳細は [design/nijiarchive_roadmap_part1_concept_requirements.md](design/nijiarchive_roadmap_part1_concept_requirements.md) の技術スタック節へ。

## 起動方法

```sh
docker compose up -d db   # 開発用PostgreSQL（ホスト側ポート5433）
bin/setup                 # 依存インストール・DB作成、最後にサーバーが起動します
```

http://localhost:3000 で確認できます。テストは `bin/rails test`、Lintは `bin/rubocop`。

## 開発状況

**Step 1（HLSアーカイブ配信MVP）を実装中**（2026-07時点）。

Step単位で完了基準を検証しながら進めています。全体計画は [design/nijiarchive_roadmap_part3_implementation_operations.md](design/nijiarchive_roadmap_part3_implementation_operations.md)、学習トラック（OSS読解・置き換え実装・計測）の設計は [design/nijiarchive_roadmap_part4_learning_tracks.md](design/nijiarchive_roadmap_part4_learning_tracks.md) を参照。

## ドキュメント

| 場所 | 内容 |
|------|------|
| [design/](design/) | roadmap 4部作（コンセプト・アーキテクチャ・実装計画・学習トラック）と各Stepの設計メモ |
| [docs/adr/](docs/adr/) | Architecture Decision Records。「なぜこの設計にしたか」の記録 |

## 注意事項

- YouTube動画の再配信は行いません。扱うのはメタデータ・埋め込み・リンクのみです（YouTube API利用規約・著作権への配慮）
- アーカイブ動画の素材は自作または権利許諾済みのもののみを使用します
