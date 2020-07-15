# frozen_string_literal: true

module Decidim
  module Initiatives
    # This module's job is to extend the API with custom fields related to
    # decidim-initiatives.
    module QueryExtensions
      # Public: Extends a type with `decidim-initiatives`'s fields.
      #
      # type - A GraphQL::BaseType to extend.
      #
      # Returns nothing.
      def self.define(type)
        type.field :initiativesTypes do
          type !types[InitiativeApiType]
          description "Lists all initiative types"

          resolve lambda { |_obj, _args, ctx|
            Decidim::InitiativesType.where(
              organization: ctx[:current_organization]
            )
          }
        end

        type.field :initiativesType do
          type InitiativeApiType
          description "Finds a initiative type"
          argument :id, !types.ID, "The ID of the initiative type"

          resolve lambda { |_obj, args, ctx|
            Decidim::InitiativesType.find_by(
              organization: ctx[:current_organization],
              id: args[:id]
            )
          }
        end
      end
    end
  end
end
