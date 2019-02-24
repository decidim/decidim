# frozen_string_literal: true

module Decidim
  module Proposals
    #
    # Decorator for collaborative drafts
    #
    class CollaborativeDraftPresenter < SimpleDelegator
      include Rails.application.routes.mounted_helpers
      include ActionView::Helpers::UrlHelper

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

      def title(links: false, extras: true)
        renderer = Decidim::ContentRenderers::HashtagRenderer.new(collaborative_draft.title)
        renderer.render(links: links, extras: extras).html_safe
      end

      def body(links: false, extras: true)
        renderer = Decidim::ContentRenderers::HashtagRenderer.new(collaborative_draft.body)
        renderer.render(links: links, extras: extras).html_safe
      end
    end
  end
end
