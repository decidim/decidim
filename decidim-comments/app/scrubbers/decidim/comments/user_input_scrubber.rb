# frozen_string_literal: true

module Decidim
  module Comments
    # Use this class as a scrubber to sanitize user input.
    # https://stackoverflow.com/a/35073814/2110884.
    class UserInputScrubber < Rails::Html::PermitScrubber
      def initialize
        super
        self.tags = custom_allowed_tags
      end

      private

      def custom_allowed_tags
        %w(p blockquote)
      end
    end
  end
end
