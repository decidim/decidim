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

        type.field :consultation,
                   Decidim::Consultations::ConsultationType,
                   null: true,
                   description: "Finds a consultation" do
          argument :id, GraphQL::Types::ID, "The ID of the participatory space", required: false
        end
      end

      def consultations(filter: {}, order: {})
        manifest = Decidim.participatory_space_manifests.select { |m| m.name == :consultations }.first

        Decidim::Core::ParticipatorySpaceListBase.new(manifest:).call(object, { filter:, order: }, context)
      end

      def consultation(id: nil)
        manifest = Decidim.participatory_space_manifests.select { |m| m.name == :consultations }.first

        Decidim::Core::ParticipatorySpaceFinderBase.new(manifest:).call(object, { id: }, context)
      end
    end
  end
end
