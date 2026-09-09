# frozen_string_literal: true

module Share
  module Content
    class Base
      def slides
        raise NotImplementedError, "#{self.class} must implement #slides"
      end

      def card_class_for(slide)
        raise NotImplementedError, "#{self.class} must implement #card_class_for"
      end

      def caption
        raise NotImplementedError, "#{self.class} must implement #caption"
      end
    end
  end
end
