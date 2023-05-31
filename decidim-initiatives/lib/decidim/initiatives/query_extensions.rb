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
        type.field :initiatives_types, [InitiativeApiType], null: false do
          description "Lists all initiative types"
        end

        type.field :initiatives_type, InitiativeApiType, null: true, description: "Finds a initiative type" do
          argument :id, GraphQL::Types::ID, "The ID of the initiative type", required: true
        end

        type.field :initiatives,
                   [Decidim::Initiatives::InitiativeType],
                   null: true,
                   description: "Lists all initiatives" do
          argument :filter, Decidim::ParticipatoryProcesses::ParticipatoryProcessInputFilter, "This argument lets you filter the results", required: false
          argument :order, Decidim::ParticipatoryProcesses::ParticipatoryProcessInputSort, "This argument lets you order the results", required: false
        end

        type.field :initiative,
                   Decidim::Initiatives::InitiativeType,
                   null: true,
                   description: "Finds a initiative" do
          argument :id, GraphQL::Types::ID, "The ID of the participatory space", required: false
        end
      end

      def initiatives_types
        Decidim::InitiativesType.where(
          organization: context[:current_organization]
        )
      end

      def initiatives_type(id:)
        Decidim::InitiativesType.find_by(
          organization: context[:current_organization],
          id:
        )
      end

      def initiatives(filter: {}, order: {})
        manifest = Decidim.participatory_space_manifests.select { |m| m.name == :initiatives }.first
        Decidim::Core::ParticipatorySpaceListBase.new(manifest:).call(object, { filter:, order: }, context)
      end

      def initiative(id: nil)
        manifest = Decidim.participatory_space_manifests.select { |m| m.name == :initiatives }.first

        Decidim::Core::ParticipatorySpaceFinderBase.new(manifest:).call(object, { id: }, context)
      end
    end
  end
end
