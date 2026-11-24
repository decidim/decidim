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
        # current_component - the component where the results belong to.
        def initialize(taxonomy_ids, result_ids, current_component)
          @result_ids = result_ids
          @current_component = current_component
          super(taxonomy_ids, results, current_component.organization)
        end

        private

        attr_reader :result_ids, :current_component

        def results
          Decidim::Accountability::Result.where(component: current_component, id: result_ids)
        end
      end
    end
  end
end
