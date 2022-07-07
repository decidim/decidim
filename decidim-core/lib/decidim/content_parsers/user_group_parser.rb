# frozen_string_literal: true

module Decidim
  module ContentParsers
    # A parser that searches user groups mentions in content.
    #
    # A word starting with `@` will be considered as a possible mention if
    # they only contains letters, numbers or underscores.
    #
    # @see BaseParser Examples of how to use a content parser
    class UserGroupParser < BaseParser
      # Class used as a container for metadata
      #
      # @!attribute groups
      #   @return [Array] an array of Decidim::UserGroup mentioned in content
      Metadata = Struct.new(:groups)

      # Matches a nickname if contains letters, numbers or underscores.
      MENTION_REGEX = /\B@(\w*)\b/

      # Replaces found mentions matching a nickname of an existing
      # group in the current organization with a global id. Other
      # mentions found that doesn't match an existing group are
      # returned as is.
      #
      # @return [String] the content with the valid mentions replaced by a global id
      def rewrite
        content.gsub(MENTION_REGEX) do |match|
          groups[match[1..-1]]&.to_global_id&.to_s || match
        end
      end

      # (see BaseParser#metadata)
      def metadata
        Metadata.new(existing_groups)
      end

      private

      def groups
        @groups ||=
          existing_groups.index_by(&:nickname)
      end

      def existing_groups
        @existing_groups ||= Decidim::UserGroup.where(organization: current_organization, nickname: content_nicknames)
      end

      def content_nicknames
        @content_nicknames ||= content.scan(MENTION_REGEX).flatten.uniq
      end

      def current_organization
        @current_organization ||= context[:current_organization]
      end
    end
  end
end
