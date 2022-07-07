# frozen_string_literal: true

module Decidim
  module ContentParsers
    # A parser that searches user mentions in content.
    #
    # A word starting with `@` will be considered as a possible mention if
    # they only contains letters, numbers or underscores.
    #
    # @see BaseParser Examples of how to use a content parser
    class UserParser < BaseParser
      # Class used as a container for metadata
      #
      # @!attribute users
      #   @return [Array] an array of Decidim::User mentioned in content
      Metadata = Struct.new(:users)

      # Matches a nickname if contains letters, numbers or underscores.
      MENTION_REGEX = /\B@(\w*)\b/

      # Replaces found mentions matching a nickname of an existing
      # user in the current organization with a global id. Other
      # mentions found that doesn't match an existing user are
      # returned as is.
      #
      # @return [String] the content with the valid mentions replaced by a global id
      def rewrite
        content.gsub(MENTION_REGEX) do |match|
          users[match[1..-1].downcase]&.to_global_id&.to_s || match
        end
      end

      # (see BaseParser#metadata)
      def metadata
        Metadata.new(existing_users)
      end

      private

      def users
        @users ||=
          existing_users.index_by(&:nickname)
      end

      def existing_users
        @existing_users ||= Decidim::User.where("decidim_organization_id = ? AND LOWER(nickname) IN (?)", current_organization.id, content_nicknames)
      end

      def content_nicknames
        @content_nicknames ||= content.scan(MENTION_REGEX).flatten.uniq.map!(&:downcase)
      end

      def current_organization
        @current_organization ||= context[:current_organization]
      end
    end
  end
end
