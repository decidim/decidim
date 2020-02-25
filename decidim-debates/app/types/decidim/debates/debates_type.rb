# frozen_string_literal: true

module Decidim
  module Debates
    DebatesType = GraphQL::ObjectType.define do
      interfaces [-> { Decidim::Core::ComponentInterface }]

      name "Debates"
      description "A debates component of a participatory space."

      connection :debates, DebateType.connection_type do
        resolve ->(component, _args, _ctx) {
          DebatesTypeHelper.base_scope(component).includes(:component)
        }
      end

      field(:debate, DebateType) do
        argument :id, !types.ID

        resolve ->(component, args, _ctx) {
          DebatesTypeHelper.base_scope(component).find_by(id: args[:id])
        }
      end
    end

    module DebatesTypeHelper
      def self.base_scope(component)
        Debate.where(component: component)
      end
    end
  end
end
