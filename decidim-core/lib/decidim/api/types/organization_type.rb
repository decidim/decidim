# frozen_string_literal: true

module Decidim
  module Core
    class OrganizationType < Decidim::Api::Types::BaseObject
      description "The current organization"

      field :name, Decidim::Core::TranslatedFieldType, "The name of the current organization", null: true
      field :taxonomies, [Decidim::Core::TaxonomyType, { null: true }], "The taxonomies associated to this organization", null: true

      field :stats, [Core::StatisticType, { null: true }], description: "The statistics associated to this object", null: true

      def stats
        Decidim::HomeStatsPresenter.new(organization: object).collection.map do |stat|
          [object, stat]
        end
      end

      def taxonomies
        object.taxonomies.roots
      end
    end
  end
end
