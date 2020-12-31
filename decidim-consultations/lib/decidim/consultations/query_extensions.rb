# frozen_string_literal: true

module Decidim
  module Consultations
    # This module's job is to extend the API with custom fields related to
    # decidim-assemblies.
    module QueryExtensions
      # Public: Extends a type with `decidim-assemblies`'s fields.
      #
      # type - A GraphQL::BaseType to extend.
      #
      # Returns nothing.
      def self.included(type)

        type.field :consultations,
                   [Decidim::Consultations::ConsultationType],
                   null: true,
                   description: "Lists all consultations" do
          argument :filter, Decidim::ParticipatoryProcesses::ParticipatoryProcessInputFilter, "This argument let's you filter the results", required: false
          argument :order, Decidim::ParticipatoryProcesses::ParticipatoryProcessInputSort, "This argument let's you order the results", required: false
        end

        def consultations(filter: {}, order: {})
          manifest = Decidim.participatory_space_manifests.select { |m| m.name == :consultations }.first

          Decidim::Core::ParticipatorySpaceList.new(manifest: manifest).call(object, { filter: filter, order: order }, context)
        end

        type.field :consultation,
                   Decidim::Consultations::ConsultationType,
                   null: true,
                   description: "Finds a consultation" do
          argument :id, GraphQL::Types::ID, "The ID of the participatory space", required: false
        end

        def consultation(id: nil)
          manifest = Decidim.participatory_space_manifests.select { |m| m.name == :consultations }.first

          Decidim::Core::ParticipatorySpaceFinder.new(manifest: manifest).call(object, { id: id }, context)
        end

      end
    end
  end
end
