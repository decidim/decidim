# frozen_string_literal: true

module Decidim
  module ContentParsers
    class BaseParser
      attr_reader :content

      # Gets initialized with the `content` to parse. It can either receive
      # already rewritten content or regular content.
      def initialize(content)
        @content = content || ""
      end

      # Parse the the `content` and return it modified
      def rewrite
        raise NotImplementedError
      end

      # Returns a hash with metadata (potentially the found entities). This metadata is
      # accessible at parsing time so it can be acted upon (sending emails to the users)
      # or maybe even stored at the DB for later consultation.
      #
      # Override this method in your content parser class if you need to return any data
      def metadata
        {}
      end
    end
  end
end
