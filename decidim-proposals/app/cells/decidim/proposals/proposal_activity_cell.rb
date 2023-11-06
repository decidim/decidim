# frozen_string_literal: true

module Decidim
  module Proposals
    # A cell to display when actions happen on a proposal.
    class ProposalActivityCell < ActivityCell
      def title
        action == "update" ? I18n.t("decidim.proposals.last_activity.proposal_updated") : I18n.t("decidim.proposals.last_activity.new_proposal")
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
