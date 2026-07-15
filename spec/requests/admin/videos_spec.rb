require "rails_helper"

RSpec.describe "Admin::Videos", type: :request do
  before do
    allow(Rails.application.credentials).to receive(:r2).and_return(
      account_id: "test-account",
      access_key_id: "test-key",
      secret_access_key: "test-secret",
      bucket: "test-bucket"
    )
  end

  describe "POST /admin/videos" do
    it "pendingのVideoを作成し、そのIDとアップロード先URLを返す" do
      expect { post admin_videos_path }.to change(Video, :count).by(1)

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(Video.find(body["video_id"])).to be_pending
      expect(body["upload_url"]).to include("videos/#{body['video_id']}/original.mp4")
    end
  end

  describe "POST /admin/videos/:id/complete" do
    let(:video) { create(:video) }

    context "R2にオブジェクトが実在するとき" do
      it "uploadedに遷移する" do
        allow_any_instance_of(Aws::S3::Client).to receive(:head_object).and_return(true)

        post complete_admin_video_path(video)

        expect(response).to have_http_status(:ok)
        expect(video.reload).to be_uploaded
      end
    end

    context "R2にオブジェクトが無いとき" do
      it "422を返しpendingのまま遷移しない" do
        allow_any_instance_of(Aws::S3::Client).to receive(:head_object)
          .and_raise(Aws::S3::Errors::NotFound.new(nil, "not found"))

        post complete_admin_video_path(video)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(video.reload).to be_pending
      end
    end

    context "既にuploadedのとき（完了通知の再送）" do
      it "R2に問い合わせず200を返す（冪等）" do
        video.mark_as_uploaded!
        expect_any_instance_of(Aws::S3::Client).not_to receive(:head_object)

        post complete_admin_video_path(video)

        expect(response).to have_http_status(:ok)
        expect(video.reload).to be_uploaded
      end
    end
  end
end
