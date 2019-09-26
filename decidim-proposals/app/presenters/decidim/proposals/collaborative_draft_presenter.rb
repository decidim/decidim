# frozen_string_literal: true

module Decidim
  module Proposals
    #
    # Decorator for collaborative drafts
    #
    class CollaborativeDraftPresenter < SimpleDelegator
      include Rails.application.routes.mounted_helpers
      include ActionView::Helpers::UrlHelper
      include ActionView::Helpers::SanitizeHelper
      include Decidim::SanitizeHelper

      def author
        coauthorship = __getobj__.coauthorships.first
        @author ||= if coauthorship.user_group
                      Decidim::UserGroupPresenter.new(coauthorship.user_group)
                    else
                      Decidim::UserPresenter.new(coauthorship.author)
                    end
      end

      def collaborative_draft
        __getobj__
      end

      def collaborative_draft_path
        Decidim::ResourceLocatorPresenter.new(collaborative_draft).path
      end

      def title(links: false, extras: true, html_escape: false)
        text = collaborative_draft.title
        text = decidim_html_escape(text) if html_escape

        renderer = Decidim::ContentRenderers::HashtagRenderer.new(text)
        renderer.render(links: links, extras: extras).html_safe
      end

      def body(links: false, extras: true, strip_tags: false)
        text = collaborative_draft.body
        text = strip_tags(text) if strip_tags

        renderer = Decidim::ContentRenderers::HashtagRenderer.new(text)
        text = renderer.render(links: links, extras: extras).html_safe

        Anchored::Linker.auto_link(text, target: "_blank", rel: "noopener")
      end
    end
  end
end
