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
        type.field :participatoryProcessGroups do
          type !types[ParticipatoryProcessGroupType]
          description "Lists all participatory process groups"

          resolve lambda { |_obj, _args, ctx|
            Decidim::ParticipatoryProcessGroup.where(
              organization: ctx[:current_organization]
            )
          }
        end

        type.field :participatoryProcessGroup do
          type ParticipatoryProcessGroupType
          description "Finds a participatory process group"
          argument :id, !types.ID, "The ID of the Participatory process group"

          resolve lambda { |_obj, args, ctx|
            Decidim::ParticipatoryProcessGroup.find_by(
              organization: ctx[:current_organization],
              id: args[:id]
            )
          }
        end
      end
    end
  end
end
