# frozen_string_literal: true

module Decidim
  module ContentParsers
    # A parser that searches resource mentions in content.
    #
    # A word starting with `/` will be considered as a possible mention if
    # they only contains letters, numbers or underscores.
    #
    # @see BaseParser Examples of how to use a content parser
    class MentionResourceParser < TagParser
      private

      def tag_data_type
        "mentionResource"
      end

      def replace_tags(text)
        text
      end
    end
  end
end
