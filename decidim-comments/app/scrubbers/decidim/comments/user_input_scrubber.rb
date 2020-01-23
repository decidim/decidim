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
        Loofah::HTML5::SafeList::ALLOWED_ELEMENTS_WITH_LIBXML2 # + %w(blockquote)
      end
    end
  end
end
