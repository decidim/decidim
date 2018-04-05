# frozen_string_literal: true

module Decidim
  module ContentParsers
    # A parser that searches user mentions in content.
    #
    # A word starting with `@` will be considered as a possible mention if
    # they only contains letters, numbers or underscores. If the `@` is
    # followed with an underscore, then it is not considered.
    #
    # @see BaseParser Examples of how to use a content parser
    class UserParser < BaseParser
      # Class used as a container for metadata
      #
      # @!attribute users
      #   @return [Array] an array of Decidim::User mentioned in content
      Metadata = Struct.new(:users)

      # Matches a nickname if they start with a letter or number
      # and only contains letters, numbers or underscores.
      MENTION_REGEX = /(^|\s)@([a-zA-Z0-9]\w*)/

      # Replaces found mentions matching a nickname of an existing
      # user in the current organization with a global id. Other
      # mentions found that doesn't match an existing user are
      # returned as is.
      #
      # @return [String] the content with the valid mentions replaced by a global id
      def rewrite
        content.gsub(MENTION_REGEX) do |match|
          if (user = Decidim::User.find_by(nickname: Regexp.last_match[2], organization: context[:current_organization]))
            Regexp.last_match[1] + user.to_global_id.to_s
          else
            match
          end
        end
      end

      # (see BaseParser#metadata)
      def metadata
        Metadata.new(
          Decidim::User.where(nickname: content.scan(MENTION_REGEX).flatten, organization: context[:current_organization])
        )
      end
    end
  end
end
