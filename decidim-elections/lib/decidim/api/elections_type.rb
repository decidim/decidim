# frozen_string_literal: true

module Decidim
  module Elections
    class ElectionsType < Decidim::Api::Types::BaseObject
      implements Decidim::Core::ComponentInterface

      graphql_name "Elections"
      description "An elections component of a participatory space."

      field :elections, Decidim::Elections::ElectionType.connection_type, null: true, connection: true

      def elections
        ElectionsTypeHelper.base_scope(object).includes(:component)
      end

      field :election, Decidim::Elections::ElectionType, null: true do
        argument :id, GraphQL::Types::ID, required: true
      end

      def election(**args)
        ElectionsTypeHelper.base_scope(object).find_by(id: args[:id])
      end
    end

    module ElectionsTypeHelper
      def self.base_scope(component)
        Election.where(component:).where.not(published_at: nil)
      end
    end
  end
end
