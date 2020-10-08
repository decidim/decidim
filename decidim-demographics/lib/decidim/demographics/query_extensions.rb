# frozen_string_literal: true

module Decidim
  module Demobraphics
    # This module's job is to extend the API with custom fields related to
    # decidim-participatory_processes.
    module QueryExtensions
      # Public: Extends a type with `decidim-participatory_processes`'s fields.
      #
      # type - A GraphQL::BaseType to extend.
      #
      # Returns nothing.
      def self.define(type)
        type.field :demographicsTypes do
          type !types[DemographicsTypeType]
          description "Demographics Data"

          resolve lambda { |_obj, _args, ctx|
            Decidim::Demographics.where(
              organization: ctx[:current_organization]
            )
          }
        end

        type.field :demographicsType do
          type DemographicsTypeType
          description "Finds an demographic type group"
          argument :id, !types.ID, "The ID of the Demographics type"

          resolve lambda { |_obj, args, ctx|
            Decidim::DemographicType.find_by(
              organization: ctx[:current_organization],
              id: args[:id]
            )
          }
        end
      end
    end
  end
end




