# frozen_string_literal: true

module Decidim
  module Assemblies
    # This module's job is to extend the API with custom fields related to
    # decidim-assemblies.
    module QueryExtensions
      # Public: Extends a type with `decidim-assemblies`'s fields.
      #
      # type - A GraphQL::BaseType to extend.
      #
      # Returns nothing.
      def self.included(type)
        type.field :assemblies_types, [AssembliesTypeType], null: false, description: "Lists all assemblies types"

        def assemblies_types(args: {})
          Decidim::AssembliesType.where(
            organization: context[:current_organization]
          )
        end

        type.field :assemblies_type, AssembliesTypeType, null: false, description: "Finds an assemblies type group"  do
          argument :id, GraphQL::Types::ID, description: "The ID of the Assemblies type", required: true
        end

        def assemblies_type(args: {})
          Decidim::AssembliesType.find_by(
            organization: context[:current_organization],
            id: args[:id]
          )
        end
      end
    end
  end
end
