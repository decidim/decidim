# frozen_string_literal: true

module Decidim
  # This module's job is to extend the API with custom fields related to
  # decidim-core.
  module QueryExtensions
    # Public: Extends a type with `decidim-core`'s fields.
    #
    # type - A GraphQL::BaseType to extend.
    #
    # Returns nothing.
    def self.define(type)
      Decidim.participatory_space_manifests.each do |participatory_space_manifest|
        type.field participatory_space_manifest.name.to_s.camelize(:lower) do
          type !types[participatory_space_manifest.api_type.constantize]
          description "Lists all #{participatory_space_manifest.name}"

          resolve lambda { |_obj, _args, ctx|
            participatory_space_manifest.model_class_name.constantize.public_spaces.where(
              organization: ctx[:current_organization]
            )
          }
        end
      end

      type.field :session do
        type Core::SessionType
        description "Return's information about the logged in user"

        resolve lambda { |_obj, _args, ctx|
          ctx[:current_user]
        }
      end

      type.field :decidim, Core::DecidimType, "Decidim's framework properties." do
        resolve ->(_obj, _args, _ctx) { Decidim }
      end
    end
  end
end
