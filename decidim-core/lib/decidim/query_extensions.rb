# frozen_string_literal: true

require "decidim/api/component_interface"
require "decidim/api/participatory_space_interface"

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
          type types[participatory_space_manifest.query_type.constantize]
          description "Lists all #{participatory_space_manifest.name}"

          resolve lambda { |_obj, _args, ctx|
            participatory_space_manifest.model_class_name.constantize.public_spaces.where(
              organization: ctx[:current_organization]
            )
          }
        end

        type.field participatory_space_manifest.name.to_s.singularize.camelize(:lower) do
          type participatory_space_manifest.query_type.constantize
          description "Finds a #{participatory_space_manifest.name.to_s.singularize}"
          argument :id, !types.ID, "The ID of the #{participatory_space_manifest.name.to_s.singularize}"

          resolve lambda { |_obj, args, ctx|
            participatory_space_manifest.model_class_name.constantize.public_spaces.find_by(
              organization: ctx[:current_organization],
              id: args[:id]
            )
          }
        end
      end

      type.field :component, Decidim::Core::ComponentInterface do
        description "Lists the components this space contains."
        argument :id, !types.ID, "The ID of the component to be found"

        resolve lambda { |_, args, ctx|
                  component = Decidim::Component.published.find_by(id: args[:id])
                  component&.organization == ctx[:current_organization] ? component : nil
                }
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

      type.field :organization, Core::OrganizationType, "The current organization" do
        resolve ->(_obj, _args, ctx) { ctx[:current_organization] }
      end

      type.field :hashtags do
        type types[Core::HashtagType]
        description "The hashtags for current organization"
        argument :name, types.String, "The name of the hashtag"

        resolve lambda { |_obj, args, ctx|
          Decidim::HashtagsResolver.new(ctx[:current_organization], args[:name]).hashtags
        }
      end
    end
  end
end
