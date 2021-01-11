# frozen_string_literal: true

module Decidim
  module Demographics
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
          type !types[DemographicsType]
          description "Demographics Data"

          resolve lambda { |_obj, _args, _ctx|
            Decidim::Demographics::Demographic.all
          }
        end
      end
    end
  end
end
