# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This module's job is to extend the API with custom fields related to
    # decidim-comments.
    module QueryExtensions
      # Public: Extends a type with `decidim-comments`'s fields.
      #
      # type - A GraphQL::BaseType to extend.
      #
      # Returns nothing.
      def self.define(type)
        type.field :participatoryProcess do
          type ParticipatoryProcessType
          description "Finds a ParticipatoryProcesses by slug or id"
          argument :id, types.ID, "The ID of the ParticipatoryProcess"
          argument :slug, types.String, "The Slug of the ParticipatoryProcess"

          resolve lambda { |_obj, args, ctx|
            q = {organization: ctx[:current_organization]}
            args[:slug] ? q[:slug] = args[:slug] : q[:id] = args[:id]
            ParticipatoryProcess.public_spaces.find_by(q)
          }
        end
      end
    end
  end
end
