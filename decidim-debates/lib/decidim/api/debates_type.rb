# frozen_string_literal: true

module Decidim
  module Debates
    class DebatesType < Decidim::Api::Types::BaseObject
      implements Decidim::Core::ComponentInterface

      graphql_name "Debates"
      description "A debates component of a participatory space."

      field :debates, Decidim::Debates::DebateType.connection_type, null: true, connection: true

      def debates
        Debate.where(component: object).includes(:component)
      end

      field :debate, Decidim::Debates::DebateType, null: true do
        argument :id, GraphQL::Types::ID, required: true
      end

      def debate(**args)
        Debate.where(component: object).find_by(id: args[:id])
      end
    end
  end
end
