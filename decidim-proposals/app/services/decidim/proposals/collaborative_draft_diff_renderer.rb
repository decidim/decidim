# frozen_string_literal: true

module Decidim
  module Proposals
    class CollaborativeDraftDiffRenderer < DiffRenderer
      private

      def attribute_types
        {
          title: :string,
          body: :string,
          decidim_category_id: :category,
          decidim_scope_id: :scope,
          address: :string,
          latitude: :string,
          longitude: :string,
          decidim_proposals_proposal_state_id: :string
        }
      end
    end
  end
end
