# frozen_string_literal: true

module Decidim
  module Exporters
    class OpenDataTaxonomySerializer < Decidim::Exporters::Serializer
      # Public: Initializes the serializer with a resource
      def initialize(resource)
        @resource = resource
      end

      # Public: Exports a hash with the serialized data for this resource.
      def serialize
        {
          id: resource.id,
          name: resource.name,
          parent_id: resource.parent_id,
          weight: resource.weight,
          children_count: resource.children_count,
          taxonomizations_count: resource.taxonomizations_count,
          created_at: resource.created_at,
          updated_at: resource.updated_at,
          filters_count: resource.filters_count,
          filter_items_count: resource.filter_items_count,
          part_of: resource.part_of,
          is_root: resource.root?
        }
      end
    end
  end
end
