# frozen_string_literal: true

module Decidim
  module Proposals
    # A form object to be used when public users want to create a Collaborative Draft.
    class CollaborativeDraftForm < Decidim::Proposals::ProposalForm

      def map_model(model)
        self.user_group_id = nil
        return unless model.categorization

        self.category_id = model.categorization.decidim_category_id
      end
    end
  end
end
