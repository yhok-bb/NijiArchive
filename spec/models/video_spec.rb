require "rails_helper"

RSpec.describe Video, type: :model do
  # 期待する遷移表をモデルのTRANSITIONSとは独立に持つ
  # （モデル側の定義ミスにテストが追従してしまうのを防ぐ）
  ALL_STATES = %i[pending uploaded transcoding ready published failed].freeze

  {
    mark_as_uploaded!: { to: :uploaded, from: %i[pending] },
    mark_as_transcoding!: { to: :transcoding, from: %i[uploaded] },
    mark_as_ready!: { to: :ready, from: %i[transcoding] },
    mark_as_published!: { to: :published, from: %i[ready] },
    mark_as_failed!: { to: :failed, from: %i[pending transcoding] }
  }.each do |method, rule|
    describe "##{method}" do
      rule[:from].each do |state|
        it "#{state}から#{rule[:to]}に遷移し永続化される" do
          video = create(:video, status: state)

          video.public_send(method)

          expect(video.reload.status).to eq(rule[:to].to_s)
        end
      end

      (ALL_STATES - rule[:from]).each do |state|
        it "#{state}からはInvalidTransitionが発生しstatusは変わらない" do
          video = create(:video, status: state)

          expect { video.public_send(method) }.to raise_error(Video::InvalidTransition)
          expect(video.reload.status).to eq(state.to_s)
        end
      end
    end
  end
end
