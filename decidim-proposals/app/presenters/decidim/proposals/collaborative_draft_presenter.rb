# frozen_string_literal: true

module Decidim
  module Proposals
    #
    # Decorator for collaborative drafts
    #
    class CollaborativeDraftPresenter < ProposalPresenter
      def author
        @author ||= Decidim::UserPresenter.new(__getobj__.coauthorships.first.author)
      end

      alias collaborative_draft proposal

      def collaborative_draft_path
        Decidim::ResourceLocatorPresenter.new(collaborative_draft).path
      end
    end
  end
end
