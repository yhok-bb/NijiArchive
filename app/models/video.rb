class Video < ApplicationRecord
  class InvalidTransition < StandardError; end

  enum :status, {
    pending: 0,      # Presigned URL発行済み・アップロード未確認
    uploaded: 1,     # R2にオブジェクトの実在を確認済み
    transcoding: 2,  # HLS変換ジョブ実行中
    ready: 3,        # 変換完了・公開はまだ（管理者の判断待ち）
    published: 4,    # 管理者が公開を決定
    failed: 5        # 変換失敗
  }

  # 遷移先 => 許可される遷移元。一直線のパイプライン＋エラーの落とし穴という構造
  # （failedへはtranscodingの失敗のほか、期限切れpendingの掃除ジョブからも入る）
  TRANSITIONS = {
    uploaded: %i[pending],
    transcoding: %i[uploaded],
    ready: %i[transcoding],
    published: %i[ready],
    failed: %i[pending transcoding]
  }.freeze

  TRANSITIONS.each do |to, from|
    define_method("mark_as_#{to}!") do
      raise InvalidTransition, "#{status}から#{to}へは遷移できません" unless from.include?(status.to_sym)

      update!(status: to)
    end
  end
end
