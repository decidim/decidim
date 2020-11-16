# frozen_string_literal: true

module Decidim
  module Core
    module ComponentInterface
      include GraphQL::Schema::Interface

      # name "ComponentInterface"
      # description "This interface is implemented by all components that belong into a Participatory Space"

      field :id, GraphQL::Types::ID, null: false, description: "The Component's unique ID"
      field :name, TranslatedFieldType, null: false, description: "The name of this component."
      field :weight, GraphQL::Types::Int, null: false, description: "The weight of the component"
      field :participatorySpace, ParticipatorySpaceType, null: false, description: "The participatory space in which this component belongs to."

      def participatorySpace
        object.participatory_space
      end

      definition_methods do
        def resolve_type(object, context)
          object.manifest.query_type.constantize
        end
      end
    end
  end
end
