# Use this hook to configure the litestream-ruby gem.
# All configuration options will be available as environment variables, e.g.
# config.replica_bucket becomes LITESTREAM_REPLICA_BUCKET
# This allows you to configure Litestream using Rails encrypted credentials,
# or some other mechanism where the values are only available at runtime.

Rails.application.configure do
  litestream_credentials = Rails.application.credentials.litestream

  config.litestream.replica_bucket = litestream_credentials&.replica_bucket
  config.litestream.replica_key_id = litestream_credentials&.replica_key_id
  config.litestream.replica_access_key = litestream_credentials&.replica_access_key
end
