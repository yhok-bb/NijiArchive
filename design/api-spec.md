# NijiArchive API仕様

**作成日:** 2026-07-06
**ステータス:** Draft
**元資料:** roadmap Part 2 §3。REST と Action Cable の使い分け理由は ADR-0007。

---

## 1. 共通事項

- ベースパス: `/api/v1`
- 認証: セッションCookie（Rails 8 Authentication Generator）。SPA化しないためトークン認証は採用しない <!-- 要確認: Hotwire前提。フロントをSPAにするならここが変わる -->
- レスポンス: JSON。エラーは `{ "error": { "code": "...", "message": "..." } }`
- 管理系（`admin: true` 必須）は 403 を返す

## 2. REST API

### 動画

```
GET /api/v1/videos
```
公開済み動画の一覧。ページネーションあり（`page`, `per`）。

```json
{ "videos": [ { "id": "uuid", "title": "…", "duration_seconds": 5400,
    "published_at": "…", "thumbnail_url": "…" } ], "total_pages": 3 }
```

```
GET /api/v1/videos/:id            # 要ログイン
```
動画詳細＋視聴用Presigned URL。**このレスポンスがPresigned URL発行のタイミング**（視聴ページを開いた瞬間。有効期限30分、期限切れはクライアントが再取得）。

```json
{ "id": "uuid", "title": "…", "hls_url": "https://…master.m3u8?signature=…",
  "hls_url_expires_at": "…", "duration_seconds": 5400,
  "resume_position_seconds": 1234 }
```

```
POST   /api/v1/videos             # 管理者。MP4アップロード（Active Storage direct upload）
PATCH  /api/v1/videos/:id         # 管理者。title/description/statusの更新（公開切替を含む）
DELETE /api/v1/videos/:id         # 管理者。R2上のHLS成果物も削除する
```

### コメント・ハイライト・関連動画

```
GET  /api/v1/videos/:id/comments?from=0&to=300   # 再生位置レンジで取得、ページネーション
POST /api/v1/videos/:id/comments                 # 要ログイン。body, video_timestamp_seconds
GET  /api/v1/videos/:id/highlights               # 盛り上がりポイント一覧（シークバーマーカー用）
GET  /api/v1/videos/:id/related                  # 関連動画一覧（DBから返す。YouTube APIは直接叩かない）
```

コメント投稿の応答は `202 Accepted`（永続化は非同期のため。→ ADR-0003）。ブロードキャストはAction Cable側で行う。
<!-- 要確認: 投稿もCommentsChannelのreceiveに寄せる案もある（roadmap Part2はチャンネル案）。REST投稿+Cable配信に倒したのは、投稿にバリデーション・認可・レートリミット（WAF）を素直に効かせるため。実装時に再判断 -->

### 認証

```
POST   /api/v1/sessions           # ログイン（email, password）
DELETE /api/v1/sessions           # ログアウト
POST   /api/v1/users              # ユーザー登録
```

## 3. Action Cable チャンネル

すべて `video_id` をパラメータに購読する。認証済みコネクションのみ（`connect` で reject）。

### CommentsChannel

| 方向 | イベント | ペイロード |
|------|---------|-----------|
| S→C | comment_created | `{ id, user_name, body, video_timestamp_seconds, created_at }` |

投稿はREST（上記）。チャンネルは配信専用。

### PresenceChannel（同時ログイン制限）

| 方向 | イベント | ペイロード |
|------|---------|-----------|
| C→S | (subscribed) | — sessionsレコード作成を試行。`user_id` ユニーク制約違反なら reject し、`{ reason: "already_watching" }` を返す |
| C→S | heartbeat | `{}` 30秒間隔 <!-- 要確認: 間隔とタイムアウト(60秒)のバランスは実測で調整 --> |
| S→C | (unsubscribed/切断) | — connection_id でsessionsレコード削除 |

### ViewerCountChannel

| 方向 | イベント | ペイロード |
|------|---------|-----------|
| S→C | viewer_count | `{ count }` 5秒間隔でSolid Cacheの現在値をブロードキャスト |

### DashboardChannel（軸2）

| 方向 | イベント | ペイロード |
|------|---------|-----------|
| C→S | level_switched | `{ bitrate, resolution, timestamp }`（hls.js LEVEL_SWITCHEDのフック） |
| C→S | playback_sample | `{ bitrate_bucket, buffer_length, timestamp }` **5秒に1回のサンプリング必須**（設計原則3） |
| C→S | cdn_cache_sample | `{ hit: bool }`（cf-cache-statusヘッダ。取得できる場合のみ） |
| S→C | stats_updated | `{ distribution: { "1080p": 12, "720p": 30, "360p": 5 }, measured_at }` 5秒間隔 |
| S→C | abr_event | 他視聴者を含むABR切り替えのタイムラインログ（直近N件のみ保持、無限に溜めない） |

サーバー側集計はSolid Cache上で行い、スナップショットを `viewer_stats` に間引き永続化（→ data-model.md §2）。

## 4. 設計上の不変条件

1. DashboardChannelが完全に落ちても、動画再生・コメントは影響を受けない（→ ADR-0004）
2. クライアント計測イベントはサンプリングなしで送らない
3. YouTube APIをリクエスト経路で同期的に叩くエンドポイントは作らない（→ ADR-0006）
