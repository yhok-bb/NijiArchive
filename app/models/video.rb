class Video < ApplicationRecord
  enum :status, {
    pending: 0,      # Presigned URL発行済み・アップロード未確認
    uploaded: 1,     # R2にオブジェクトの実在を確認済み
    transcoding: 2,  # HLS変換ジョブ実行中
    ready: 3,        # 変換完了・公開はまだ（管理者の判断待ち）
    published: 4,    # 管理者が公開を決定
    failed: 5        # 変換失敗
  }
end
