# frozen_string_literal: true

module Decidim
  module Debates
    class DebatesType < Decidim::Api::Types::BaseObject
      implements Decidim::Core::ComponentInterface

      graphql_name "Debates"
      description "A debates component of a participatory space."

      field :debates, DebateType.connection_type, null: true, connection: true

      def debates
        DebatesTypeHelper.base_scope(object).includes(:component)
      end

      field :debate, DebateType, null: true do
        argument :id, ID, required: true
      end

      def debate(**args)
        DebatesTypeHelper.base_scope(object).find_by(id: args[:id])
      end
    end

    module DebatesTypeHelper
      def self.base_scope(component)
        Debate.where(component: component)
      end
    end
  end
end
