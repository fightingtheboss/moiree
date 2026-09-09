# frozen_string_literal: true

module Share
  module Publisher
    class Base
      def publish!(image_urls:, caption:)
        raise NotImplementedError, "#{self.class} must implement #publish!"
      end
    end
  end
end
