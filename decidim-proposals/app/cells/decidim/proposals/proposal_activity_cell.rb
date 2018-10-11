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
    end
  end
end
