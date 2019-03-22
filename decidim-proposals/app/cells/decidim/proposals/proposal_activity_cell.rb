# frozen_string_literal: true

module Decidim
  module Proposals
    # A cell to display when a proposal has been published.
    class ProposalActivityCell < ActivityCell
      def title
        I18n.t(
          "decidim.proposals.last_activity.new_proposal_at_html",
          link: participatory_space_link
        )
      end

      def resource_link_text
        presenter.title
      end

      def description
        presenter.body(links: true)
      end

      def presenter
        @presenter ||= Decidim::Proposals::ProposalPresenter.new(resource)
      end
    end
  end
end
