# frozen_string_literal: true

module Decidim
  module Conferences
    # This module's job is to extend the API with custom fields related to
    # decidim-assemblies.
    module QueryExtensions
      # Public: Extends a type with `decidim-assemblies`'s fields.
      #
      # type - A GraphQL::BaseType to extend.
      #
      # Returns nothing.
      def self.included(type)
        type.field :conferences,
                   [Decidim::Conferences::ConferenceType],
                   null: true,
                   description: "Lists all conferences" do
          argument :filter, Decidim::ParticipatoryProcesses::ParticipatoryProcessInputFilter, "This argument lets you filter the results", required: false
          argument :order, Decidim::ParticipatoryProcesses::ParticipatoryProcessInputSort, "This argument lets you order the results", required: false
        end

        type.field :conference,
                   Decidim::Conferences::ConferenceType,
                   null: true,
                   description: "Finds a conference" do
          argument :id, GraphQL::Types::ID, "The ID of the participatory space", required: false
        end
      end

      def conferences(filter: {}, order: {})
        manifest = Decidim.participatory_space_manifests.select { |m| m.name == :conferences }.first

        Decidim::Core::ParticipatorySpaceListBase.new(manifest: manifest).call(object, { filter: filter, order: order }, context)
      end

      def conference(id: nil)
        manifest = Decidim.participatory_space_manifests.select { |m| m.name == :conferences }.first

        Decidim::Core::ParticipatorySpaceFinderBase.new(manifest: manifest).call(object, { id: id }, context)
      end
    end
  end
end
