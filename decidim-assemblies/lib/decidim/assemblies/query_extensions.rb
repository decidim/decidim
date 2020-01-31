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
      def self.define(type)
        type.field :assembliesTypes do
          type !types[AssembliesTypeType]
          description "Lists all assemblies types"

          resolve lambda { |_obj, _args, ctx|
            Decidim::AssembliesType.where(
              organization: ctx[:current_organization]
            )
          }
        end

        type.field :assembliesType do
          type AssembliesTypeType
          description "Finds an assemblies type group"
          argument :id, !types.ID, "The ID of the Assemblies type"

          resolve lambda { |_obj, args, ctx|
            Decidim::AssembliesType.find_by(
              organization: ctx[:current_organization],
              id: args[:id]
            )
          }
        end
      end
    end
  end
end
