# frozen_string_literal: true

module Decidim
  module Proposals
    #
    # NullObject to abstract out the author of an official proposal.
    #
    class OfficialAuthorPresenter
      def name
        I18n.t("decidim.proposals.models.proposal.fields.official_proposal")
      end

      def nickname
        ""
      end

      def avatar_url
        ActionController::Base.helpers.asset_path("decidim/default-avatar.svg")
      end

      def deleted?
        false
      end
    end
  end
end
