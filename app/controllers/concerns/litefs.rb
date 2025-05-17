# frozen_string_literal: true

# For use in GET requests with write side-effects when using LiteFS on Fly.io
# Ensure that the request is run on the primary instance
# https://fly.io/docs/litefs/primary/
# https://fly.io/docs/networking/dynamic-request-routing/#the-fly-replay-response-header

module LiteFS
  extend ActiveSupport::Concern

  included do
    helper_method :litefs_primary_instance_id

    def litefs_primary_instance_id
      if File.exist?("/litefs/.primary")
        File.read("/litefs/.primary").strip
      end
    end
  end
end
