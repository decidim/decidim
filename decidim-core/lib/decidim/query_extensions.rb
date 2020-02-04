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
        type.field participatory_space_manifest.name.to_s.camelize(:lower),
                   type: type.types[participatory_space_manifest.query_type.constantize],
                   description: "Lists all #{participatory_space_manifest.name}",
                   function: participatory_space_manifest.query_list.constantize.new(manifest: participatory_space_manifest)

        type.field participatory_space_manifest.name.to_s.singularize.camelize(:lower),
                   type: participatory_space_manifest.query_type.constantize,
                   description: "Finds a #{participatory_space_manifest.name.to_s.singularize}",
                   function: participatory_space_manifest.query_finder.constantize.new(manifest: participatory_space_manifest)
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

      type.field :metrics do
        type types[Decidim::Core::MetricType]
        argument :names, types[types.String], "The names of the metrics you want to retrieve"
        argument :space_type, types.String, "The type of ParticipatorySpace you want to filter with"
        argument :space_id, types.Int, "The ID of ParticipatorySpace you want to filter with"

        resolve lambda { |_, args, ctx|
                  manifests = if args[:names].blank?
                                Decidim.metrics_registry.all
                              else
                                Decidim.metrics_registry.all.select do |manifest|
                                  args[:names].include?(manifest.metric_name.to_s)
                                end
                              end
                  filters = {}
                  if args[:space_type].present? && args[:space_id].present?
                    filters[:participatory_space_type] = args[:space_type]
                    filters[:participatory_space_id] = args[:space_id]
                  end

                  manifests.map do |manifest|
                    Decidim::Core::MetricResolver.new(manifest.metric_name, ctx[:current_organization], filters)
                  end
                }
      end

      type.field :users do
        type types[Decidim::Core::UserType]
        description "The participants for the current organization"
        argument :name, types.String, "The name of the participant"
        argument :nickname, types.String, "The @nickname of the participant"
        argument :wildcard, types.String, "Either the name or the @nickname of the participant"

        resolve lambda { |_obj, args, ctx|
          filters = {}
          args.each do |argument, value|
            filters[argument.to_sym] = value.to_s if value.present?
          end
          Decidim::Core::UserResolver.new(ctx[:current_organization], filters).users
        }
      end
    end
  end
end
