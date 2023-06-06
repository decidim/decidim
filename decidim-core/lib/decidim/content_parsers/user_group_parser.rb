# frozen_string_literal: true

module Decidim
  module ContentParsers
    # A parser that searches user groups mentions in content.
    #
    # A word starting with `@` will be considered as a possible mention if
    # they only contains letters, numbers or underscores.
    #
    # @see BaseParser Examples of how to use a content parser
    class UserGroupParser < UserParser
      # Class used as a container for metadata
      #
      # @!attribute groups
      #   @return [Array] an array of Decidim::UserGroup mentioned in content
      Metadata = Struct.new(:groups)

      # Matches a nickname if contains letters, numbers or underscores.
      MENTION_REGEX = /\B@(\w*)\b/

      # (see BaseParser#metadata)
      def metadata
        Metadata.new(existing_mentionables)
      end

      private

      def mentionable_class
        Decidim::UserGroup
      end
    end
  end
end
