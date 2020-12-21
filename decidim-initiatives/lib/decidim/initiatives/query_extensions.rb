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
      def self.included(type)
        type.field :initiatives_types,[InitiativeApiType], null: false  do
          description "Lists all initiative types"
        end

        def initiatives_types
          Decidim::InitiativesType.where(
            organization: context[:current_organization]
          )
        end

        type.field :initiatives_type, InitiativeApiType, null: true, description: "Finds a initiative type" do
          argument :id, GraphQL::Types::ID, "The ID of the initiative type", required: true
        end

        def initiatives_type(args: {})
          Decidim::InitiativesType.find_by(
            organization: context[:current_organization],
            id: args[:id]
          )
        end

      end
    end
  end
end
