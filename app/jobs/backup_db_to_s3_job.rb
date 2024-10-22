# frozen_string_literal: true

class BackupDbToS3Job < ApplicationJob
  queue_as :default

  def perform(*args)
    if Rails.env.production?
      system("litefs export -name production.sqlite3 /tmp/latest.db")
      system("gzip /tmp/latest.db")

      role_credentials = Aws::AssumeRoleWebIdentityCredentials.new(
        role_arn: ENV["AWS_ROLE_ARN"],
        web_identity_token_file: ENV["AWS_WEB_IDENTITY_TOKEN_FILE"],
        role_session_name: ENV["AWS_ROLE_SESSION_NAME"],
        region: "us-east-1",
      )

      client = Aws::S3::Client.new(credentials: role_credentials, region: "us-east-1")

      client.put_object(
        bucket: "moiree",
        body: File.open("/tmp/latest.db.gz"),
        key: "moiree-production-#{Time.zone.now.strftime("%d%m%Y")}.db.gz",
      )
    end
  end
end
