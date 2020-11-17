# frozen_string_literal: true

module Decidim
  module Elections
    class ElectionsType < GraphQL::Schema::Object
      graphql_name "Elections"
      implements Decidim::Core::ComponentInterface

      description "An elections component of a participatory space."

      field :elections, ElectionType.connection_type, null: false
      field(:page, ElectionType, null: true) do
        argument :id, ID, required: true
      end

      def page(id:)
        pages.find_by(id: id)
      end

      def pages
        ElectionsTypeHelper.base_scope(object).includes(:component)
      end
    end

    module ElectionsTypeHelper
      def self.base_scope(component)
        Election.where(component: component).where.not(published_at: nil)
      end
    end
  end
end
