# frozen_string_literal: true

module Decidim
  module ContentParsers
    class UserParser < BaseParser
      MENTION_REGEX = /(^|\s)@([a-z0-9]\w*)/

      # Rewrites the content by substituting user mentions by global id
      def rewrite
        content.gsub(MENTION_REGEX) do |match|
          if (user = Decidim::User.find_by(nickname: Regexp.last_match[2]))
            Regexp.last_match[1] + user.to_global_id.to_s
          else
            match
          end
        end
      end

      def metadata
        { users: Decidim::User.where(nickname: content.scan(MENTION_REGEX).flatten) }
      end
    end
  end
end
