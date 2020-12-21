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
      def self.define(type)
        type.field :participatory_process_groups, [ParticipatoryProcessGroupType], null: false,
          description: "Lists all participatory process groups"

        def participatory_process_groups(args: {})
          Decidim::ParticipatoryProcessGroup.where(
            organization: context[:current_organization]
          )
        end

        type.field :participatory_process_group, ParticipatoryProcessGroupType, null: false do
          description "Finds a participatory process group"
          argument :id, GraphQL::Types::ID, null: false, description: "The ID of the Participatory process group"
        end

        def participatory_process_group(args: {})
          Decidim::ParticipatoryProcessGroup.find_by(
            organization: ctx[:current_organization],
            id: args[:id]
          )
        end
      end
    end
  end
end
