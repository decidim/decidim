# frozen_string_literal: true

module Decidim
  module ContentRenderers
    # A renderer that searches Global IDs representing resources in content
    # and replaces it with a link to the resource.
    #
    # e.g. gid://<APP_NAME>/Decidim::Proposals::Proposal/1
    #
    # @see BaseRenderer Examples of how to use a content renderer
    class MentionResourceRenderer < BaseRenderer
      include Rails.application.routes.mounted_helpers
      include ActionView::Helpers::UrlHelper
      include Decidim::SanitizeHelper

      # Matches a global id representing a Decidim::Proposals::Proposal
      GLOBAL_ID_REGEX = %r{gid://[\w-]+/Decidim::Proposals::Proposal/\d+}

      # Replaces found Global IDs matching an existing proposal with
      # a link to the resource.
      #
      # @return [String] the content ready to display (contains HTML)
      def render(editor: false, **_)
        replace_pattern(content, GLOBAL_ID_REGEX, editor:)
      end

      protected

      def replace_pattern(text, pattern, editor:)
        return text unless text.respond_to?(:gsub)

        text.gsub(pattern) do |resource_gid|
          resource = GlobalID::Locator.locate(resource_gid)
          if editor
            render_editor(resource_gid, resource)
          else
            render_resource_link(resource)
          end
        rescue ActiveRecord::RecordNotFound => _e
          ""
        end
      end

      def render_editor(resource_gid, resource)
        title = presenter_for(resource).title
        %(<span data-type="mentionResource" data-id="#{resource_gid}" data-label="#{title}">#{title}</span>)
      end

      def render_resource_link(resource)
        link_to mention_title(resource), resource_path(resource)
      end

      def mention_title(resource)
        title = presenter_for(resource).title

        "<span class='editor-mention'>
          #{mention_avatar(resource)}
          <span>#{title}</span>
        </span>".html_safe
      end

      def mention_avatar(resource)
        author = resource.authors.first

        "<img src='#{author.presenter.avatar_url(:thumb)}' class='not-prose' />"
      end

      def resource_path(resource)
        Decidim::ResourceLocatorPresenter.new(resource).path
      end

      def presenter_for(resource)
        Decidim::Proposals::ProposalPresenter.new(resource)
      end
    end
  end
end
