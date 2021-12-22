# frozen-string_literal: true

module Decidim
  module Proposals
    class PublishProposalEvent < Decidim::Events::SimpleEvent
      include Decidim::Events::CoauthorEvent
      include Decidim::Core::Engine.routes.url_helpers
      include ActionView::Helpers::UrlHelper

      def resource_text
        resource.body
      end

      def i18n_options
        author_path = link_to("@#{author.nickname}", profile_path(author.nickname))
        author_string = "#{author.name} #{author_path}"
        super.merge({ author: author_string })
      end

      private

      def i18n_scope
        return super unless participatory_space_event?

        "decidim.events.proposals.proposal_published_for_space"
      end

      def participatory_space_event?
        extra[:participatory_space]
      end
    end
  end
end
