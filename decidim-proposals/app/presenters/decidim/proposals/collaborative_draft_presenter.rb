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

      def collaborative_draft_path
        draft = __getobj__
        Decidim::ResourceLocatorPresenter.new(draft).path
      end
    end
  end
end
