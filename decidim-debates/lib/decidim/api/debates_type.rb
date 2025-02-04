# frozen_string_literal: true

module Decidim
  module Debates
    class DebatesType < Decidim::Core::ComponentType
      graphql_name "Debates"
      description "A debates component of a participatory space."

      field :debate, Decidim::Debates::DebateType, "A single Debate object", null: true do
        argument :id, GraphQL::Types::ID, required: true
      end
      field :debates, Decidim::Debates::DebateType.connection_type, "A collection of Debates", null: true, connection: true

      def debates
        Debate.where(component: object).includes(:component)
      end

      def debate(**args)
        Debate.where(component: object).find_by(id: args[:id])
      end
    end
  end
end
