# frozen_string_literal: true

module Decidim
  module ContentParsers
    # A parser that searches user mentions in content.
    #
    # A word starting with `@` will be considered as a possible mention if
    # they only contains letters, numbers or underscores.
    #
    # @see BaseParser Examples of how to use a content parser
    class UserParser < TagParser
      # Class used as a container for metadata
      #
      # @!attribute users
      #   @return [Array] an array of Decidim::User mentioned in content
      Metadata = Struct.new(:users)

      # Matches a nickname if contains letters, numbers or underscores.
      MENTION_REGEX = /\B@(\w*)\b/

      # (see BaseParser#metadata)
      def metadata
        Metadata.new(existing_mentionables)
      end

      private

      def tag_data_type
        "mention"
      end

      def replace_tags(text)
        text.gsub(MENTION_REGEX) do |match|
          mentionables[match[1..-1].downcase]&.to_global_id&.to_s || match
        end
      end

      def scan_tags(text)
        text.scan(MENTION_REGEX)
      end

      def mentionable_class
        Decidim::User
      end

      def mentionables
        @mentionables ||= existing_mentionables.index_by(&:nickname)
      end

      def existing_mentionables
        @existing_mentionables ||= mentionable_class.where(
          "decidim_organization_id = ? AND nickname IN (?)",
          current_organization.id,
          content_nicknames
        )
      end

      def content_nicknames
        @content_nicknames ||= content_tags.map(&:downcase)
      end

      def current_organization
        @current_organization ||= context[:current_organization]
      end
    end
  end
end
