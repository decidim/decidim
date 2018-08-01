# frozen_string_literal: true

module Decidim
  module Proposals
    # A form object to be used when public users want to create a Collaborative Draft.
    class CollaborativeDraftForm < Decidim::Proposals::ProposalForm
      def map_model(model)
        return unless model.categorization

        self.category_id = model.categorization.decidim_category_id
      end

      def user_group
        @user_group ||= Decidim::UserGroup.find user_group_id if user_group_id.present?
      end
    end
  end
end
