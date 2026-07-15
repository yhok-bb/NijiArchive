require "aws-sdk-s3"

module Admin
  class VideosController < ApplicationController
    def new
    end

    def create
      video = Video.create!
      render json: { video_id: video.id, upload_url: presigned_upload_url(video) }
    end

    def complete
      video = Video.find(params[:id])

      # 完了通知の再送に対して冪等（レスポンスを受け損ねたクライアントが再送してくる）
      if video.uploaded?
        render json: { video_id: video.id, status: video.status }
        return
      end

      unless r2_object_exists?(video)
        render json: { error: "アップロードされたファイルがR2上で確認できません" }, status: :unprocessable_entity
        return
      end

      video.mark_as_uploaded!
      render json: { video_id: video.id, status: video.status }
    rescue Video::InvalidTransition => e
      render json: { error: e.message }, status: :conflict
    end

    private

    def presigned_upload_url(video)
      Aws::S3::Presigner.new(client: r2_client).presigned_url(
        :put_object,
        bucket: r2[:bucket],
        key: original_key(video),
        expires_in: 30.minutes.to_i
      )
    end

    def r2_object_exists?(video)
      r2_client.head_object(bucket: r2[:bucket], key: original_key(video))
      true
    rescue Aws::S3::Errors::NotFound
      false
    end

    def original_key(video)
      "videos/#{video.id}/original.mp4"
    end

    def r2_client
      @r2_client ||= Aws::S3::Client.new(
        access_key_id: r2[:access_key_id],
        secret_access_key: r2[:secret_access_key],
        endpoint: "https://#{r2[:account_id]}.r2.cloudflarestorage.com",
        region: "auto",
        force_path_style: true
      )
    end

    def r2
      @r2 ||= Rails.application.credentials.r2
    end
  end
end
