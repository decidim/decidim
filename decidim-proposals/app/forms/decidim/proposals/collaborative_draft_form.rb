# frozen_string_literal: true

module Decidim
  module Proposals
    # A form object to be used when public users want to create a Collaborative Draft.
    class CollaborativeDraftForm < Decidim::Proposals::ProposalForm
      def user_group
        @user_group ||= Decidim::UserGroup.find user_group_id if user_group_id.present?
      end
    end
  end
end
