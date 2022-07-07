# frozen_string_literal: true

module Decidim
  module ContentRenderers
    # A renderer that searches Global IDs representing users in content
    # and replaces it with a link to their profile with the nickname.
    #
    # e.g. gid://<APP_NAME>/Decidim::UserGroup/1
    #
    # @see BaseRenderer Examples of how to use a content renderer
    class UserGroupRenderer < BaseRenderer
      # Matches a global id representing a Decidim::UserGroup
      GLOBAL_ID_REGEX = %r{gid://[\w-]+/Decidim::UserGroup/\d+}

      # Replaces found Global IDs matching an existing user with
      # a link to their profile. The Global IDs representing an
      # invalid Decidim::UserGroup are replaced with an empty string.
      #
      # @return [String] the content ready to display (contains HTML)
      def render(_options = nil)
        return content unless content.respond_to?(:gsub)

        content.gsub(GLOBAL_ID_REGEX) do |user_gid|
          user = GlobalID::Locator.locate(user_gid)
          Decidim::UserGroupPresenter.new(user).display_mention
        rescue ActiveRecord::RecordNotFound => _e
          ""
        end
      end
    end
  end
end
