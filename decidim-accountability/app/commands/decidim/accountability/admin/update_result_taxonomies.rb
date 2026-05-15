# frozen_string_literal: true

module Decidim
  module Accountability
    module Admin
      # A command with all the business logic when an admin batch updates results taxonomies.
      class UpdateResultTaxonomies < UpdateResourcesTaxonomies
        # Public: Initializes the command.
        #
        # taxonomy_ids - the taxonomy ids to update
        # result_ids - the results ids to update.
        def initialize(taxonomy_ids, result_ids, organization)
          super(taxonomy_ids, Decidim::Accountability::Result.where(id: result_ids), organization)
        end
      end
    end
  end
end
