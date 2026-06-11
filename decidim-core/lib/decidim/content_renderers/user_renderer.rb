# frozen_string_literal: true

module Decidim
  module ContentRenderers
    # A renderer that searches Global IDs representing users in content
    # and replaces it with a link to their profile with the nickname.
    #
    # e.g. gid://<APP_NAME>/Decidim::User/1
    #
    # @see BaseRenderer Examples of how to use a content renderer
    class UserRenderer < BaseRenderer
      # Matches a global id representing a Decidim::User
      GLOBAL_ID_REGEX = %r{gid://[\w-]+/Decidim::User/\d+}

      # Replaces found Global IDs matching an existing user with
      # a link to their profile. The Global IDs representing an
      # invalid Decidim::User are replaced with an empty string.
      #
      # @return [String] the content ready to display (contains HTML)
      def render(editor: false, plain: false, **_)
        if plain
          replace_plain_text(content)
        else
          replace_pattern(content, GLOBAL_ID_REGEX, editor:)
        end
      end

      protected

      def replace_pattern(text, pattern, editor:)
        replace_pattern_by_context(text, pattern) do |user_gid, context|
          user = GlobalID::Locator.locate(user_gid)
          if context.attribute?
            render_profile_path(user)
          elsif editor
            render_editor(user)
          else
            render_text(user)
          end
        end
      end

      def replace_plain_text(text)
        text.gsub(GLOBAL_ID_REGEX) do
          user = GlobalID::Locator.locate(Regexp.last_match[0])
          user ? presenter_for(user).nickname : ""
        end
      end

      def render_editor(mentionable)
        mention = render_text(mentionable, editor: true)
        label = CGI.escapeHTML(mention)
        %(<span data-type="mention" data-id="#{mention}" data-label="#{label}">#{label}</span>)
      end

      def presenter_for(mentionable)
        Decidim::UserPresenter.new(mentionable)
      end

      def render_text(user, editor: false)
        if editor
          presenter_for(user).nickname
        else
          presenter_for(user).display_mention
        end
      end

      def render_profile_path(user)
        presenter_for(user).profile_path
      end
    end
  end
end
