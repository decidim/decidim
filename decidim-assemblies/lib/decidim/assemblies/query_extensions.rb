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

        type.field :assemblies_type, AssembliesTypeType, null: true, description: "Finds an assemblies type group" do
          argument :id, GraphQL::Types::ID, description: "The ID of the Assemblies type", required: true
        end

        def assemblies_type(id:)
          Decidim::AssembliesType.find_by(
            organization: context[:current_organization],
            id: id
          )
        end
        type.field :assemblies,
                   [Decidim::Assemblies::AssemblyType],
                   null: true,
                   description: "Lists all assemblies" do
          argument :filter, Decidim::ParticipatoryProcesses::ParticipatoryProcessInputFilter, "This argument let's you filter the results", required: false
          argument :order, Decidim::ParticipatoryProcesses::ParticipatoryProcessInputSort, "This argument let's you order the results", required: false
        end

        def assemblies(filter: {}, order: {})
          manifest = Decidim.participatory_space_manifests.select { |m| m.name == :assemblies }.first
          Decidim::Core::ParticipatorySpaceList.new(manifest: manifest).call(object, { filter: filter, order: order }, context)
        end

        type.field :assembly,
                   Decidim::Assemblies::AssemblyType,
                   null: true,
                   description: "Finds a assembly" do
          argument :id, GraphQL::Types::ID, "The ID of the participatory space", required: false
        end

        def assembly(id: nil)
          manifest = Decidim.participatory_space_manifests.select { |m| m.name == :assemblies }.first
          Decidim::Core::ParticipatorySpaceFinder.new(manifest: manifest).call(object, { id: id }, context)
        end
      end
    end
  end
end
