# frozen_string_literal: true

module Decidim
  module Proposals
    #
    # A dummy presenter to abstract out the author of an official proposal.
    #
    class OfficialAuthorPresenter < Decidim::OfficialAuthorPresenter
      def name
        I18n.t("decidim.proposals.models.proposal.fields.official_proposal")
      end
    end
  end
end
