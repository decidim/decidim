# frozen_string_literal: true

module Decidim
  module Admin
    module ComponentTaxonomiesHelper
      extend ActiveSupport::Concern

      included do
        helper_method :current_component_taxonomy_filters
      end

      def current_component_taxonomy_filters
        @current_component_taxonomy_filters ||= TaxonomyFilter.for(current_organization)
                                                              .for_manifest(current_participatory_space.manifest.name)
                                                              .where(id: current_component.settings.taxonomy_filters)
      end
    end
  end
end
