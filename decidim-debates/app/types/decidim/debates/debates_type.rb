# frozen_string_literal: true

module Decidim
  module Debates
    class DebatesType < GraphQL::Schema::Object
      graphql_name "Debates"
      implements Decidim::Core::ComponentInterface

      description "A debates component of a participatory space."

      field :debates, DebateType.connection_type, null: false do
        def resolve(component, _args, _ctx)
          DebatesTypeHelper.base_scope(component).includes(:component)
        end
      end

      field(:debate, DebateType, null: true) do
        argument :id, ID, required: true

        def resolve(component, args, _ctx)
          DebatesTypeHelper.base_scope(component).find_by(id: args[:id])
          end
      end
    end

    module DebatesTypeHelper
      def self.base_scope(component)
        Debate.where(component: component)
      end
    end
  end
end
