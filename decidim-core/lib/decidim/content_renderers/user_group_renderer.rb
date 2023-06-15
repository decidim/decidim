# frozen_string_literal: true

module Decidim
  module ContentRenderers
    # A renderer that searches Global IDs representing users in content
    # and replaces it with a link to their profile with the nickname.
    #
    # e.g. gid://<APP_NAME>/Decidim::UserGroup/1
    #
    # @see BaseRenderer Examples of how to use a content renderer
    class UserGroupRenderer < UserRenderer
      # Matches a global id representing a Decidim::UserGroup
      GLOBAL_ID_REGEX = %r{gid://[\w-]+/Decidim::UserGroup/\d+}

      # Replaces found Global IDs matching an existing user with
      # a link to their profile. The Global IDs representing an
      # invalid Decidim::UserGroup are replaced with an empty string.
      #
      # @return [String] the content ready to display (contains HTML)
      def render(editor: false, **_)
        replace_pattern(content, GLOBAL_ID_REGEX, editor:)
      end

      protected

      def presenter_for(mentionable)
        Decidim::UserGroupPresenter.new(mentionable)
      end
    end
  end
end
