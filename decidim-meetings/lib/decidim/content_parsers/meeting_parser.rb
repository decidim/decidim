# frozen_string_literal: true

module Decidim
  module ContentParsers
    # A parser that searches mentions of Meetings in content.
    #
    # @see BaseParser Examples of how to use a content parser
    class MeetingParser < ResourceParser
      private

      def url_regex
        %r{#{URL_REGEX_SCHEME}#{URL_REGEX_CONTENT}/meetings/#{URL_REGEX_END_CHAR}+}i
      end

      def model_class
        "Decidim::Meetings::Meeting"
      end
    end
  end
end
