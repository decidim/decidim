# frozen_string_literal: true

module Decidim
  module Proposals
    # A cell to display when actions happen on a proposal.
    class ProposalActivityCell < ActivityCell
      def title
        I18n.t(
          action_key,
          scope: "decidim.proposals.last_activity"
        )
      end

      def action_key
        action == "update" ? "proposal_updated" : "new_proposal"
      end

      def resource_link_text
        decidim_html_escape(presenter.title)
      end

      def description
        strip_tags(presenter.body(links: true))
      end

      def presenter
        @presenter ||= Decidim::Proposals::ProposalPresenter.new(resource)
      end
    end
  end
end
