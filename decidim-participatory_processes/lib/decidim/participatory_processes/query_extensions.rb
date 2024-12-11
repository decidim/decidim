# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This module's job is to extend the API with custom fields related to
    # decidim-participatory_processes.
    module QueryExtensions
      # Public: Extends a type with `decidim-participatory_processes`'s fields.
      #
      # type - A GraphQL::BaseType to extend.
      #
      # Returns nothing.
      def self.included(type)
        type.field :participatory_processes,
                   [Decidim::ParticipatoryProcesses::ParticipatoryProcessType],
                   null: true,
                   description: "Lists all participatory_processes" do
          argument :filter, Decidim::ParticipatoryProcesses::ParticipatoryProcessInputFilter, "This argument lets you filter the results", required: false
          argument :order, Decidim::ParticipatoryProcesses::ParticipatoryProcessInputSort, "This argument lets you order the results", required: false
        end

        type.field :participatory_process,
                   Decidim::ParticipatoryProcesses::ParticipatoryProcessType,
                   null: true,
                   description: "Finds a participatory_process" do
          argument :id, GraphQL::Types::ID, "The ID of the participatory space", required: false
          argument :slug, String, "The slug of the participatory process", required: false
        end

        type.field :participatory_process_groups, [ParticipatoryProcessGroupType],
                   null: false,
                   description: "Lists all participatory process groups"

        type.field :participatory_process_group, ParticipatoryProcessGroupType, null: true do
          description "Finds a participatory process group"
          argument :id, GraphQL::Types::ID, required: true, description: "The ID of the Participatory process group"
        end

        type.field :participatory_process_types, [ParticipatoryProcessTypeType],
                   null: false,
                   description: "List all participatory process types"

        type.field :participatory_process_type, ParticipatoryProcessTypeType, null: true do
          description "Finds a participatory process type"
          argument :id, GraphQL::Types::ID, required: true, description: "The ID of the participatory process type"
        end
      end

      def participatory_processes(filter: {}, order: {})
        manifest = Decidim.participatory_space_manifests.select { |m| m.name == :participatory_processes }.first
        Decidim::Core::ParticipatorySpaceListBase.new(manifest:).call(object, { filter:, order: }, context)
      end

      def participatory_process(id: nil, slug: nil)
        manifest = Decidim.participatory_space_manifests.select { |m| m.name == :participatory_processes }.first
        Decidim::Core::ParticipatorySpaceFinderBase.new(manifest:).call(object, { id:, slug: }, context)
      end

      def participatory_process_groups(*)
        Decidim::ParticipatoryProcessGroup.where(
          organization: context[:current_organization]
        )
      end

      def participatory_process_group(id:)
        Decidim::ParticipatoryProcessGroup.find_by(
          organization: context[:current_organization],
          id:
        )
      end

      def participatory_process_types(*)
        Decidim::ParticipatoryProcessType.where(
          organization: context[:current_organization]
        )
      end

      def participatory_process_type(id:)
        Decidim::ParticipatoryProcessType.find_by(
          organization: context[:current_organization],
          id:
        )
      end
    end
  end
end
