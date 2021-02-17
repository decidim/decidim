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
        type.field :participatory_process_groups, [ParticipatoryProcessGroupType],
                   null: false,
                   description: "Lists all participatory process groups"

        type.field :participatory_process_group, ParticipatoryProcessGroupType, null: true do
          description "Finds a participatory process group"
          argument :id, GraphQL::Types::ID, required: true, description: "The ID of the Participatory process group"
        end
      end

      def participatory_process_groups(*)
        Decidim::ParticipatoryProcessGroup.where(
          organization: context[:current_organization]
        )
      end

      def participatory_process_group(id:)
        Decidim::ParticipatoryProcessGroup.find_by(
          organization: context[:current_organization],
          id: id
        )
      end
    end
  end
end
