require "aws-sdk-s3"

module Admin
  class VideosController < ApplicationController
    def new
    end

    def create
      video = Video.create!
      render json: { video_id: video.id, upload_url: presigned_upload_url(video) }
    end

    private

    def presigned_upload_url(video)
      r2 = Rails.application.credentials.r2
      client = Aws::S3::Client.new(
        access_key_id: r2[:access_key_id],
        secret_access_key: r2[:secret_access_key],
        endpoint: "https://#{r2[:account_id]}.r2.cloudflarestorage.com",
        region: "auto",
        force_path_style: true
      )
      Aws::S3::Presigner.new(client: client).presigned_url(
        :put_object,
        bucket: r2[:bucket],
        key: "videos/#{video.id}/original.mp4",
        expires_in: 30.minutes.to_i
      )
    end
  end
end
