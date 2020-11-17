# frozen_string_literal: true

require "decidim/api/component_interface"
require "decidim/api/participatory_space_interface"

module Decidim
  # This module's job is to extend the API with custom fields related to
  # decidim-core.
  module QueryExtensions
    def self.prepended(base)
      base.class_eval do
        field :decidim, Core::DecidimType, null: true, description: "Decidim's framework properties."
        field :organization, Core::OrganizationType, null: true, description: "The current organization"

        field :component, Decidim::Core::ComponentInterface, null: true, description: "Lists the components this space contains." do
          argument :id, GraphQL::Types::ID, required: true, description: "The ID of the component to be found"
        end

        Decidim.participatory_space_manifests.each do |participatory_space_manifest|
          field participatory_space_manifest.name.to_s.camelize(:lower),
                type: [participatory_space_manifest.query_type.constantize],
                null: true,
                description: "Lists all #{participatory_space_manifest.name}"
          # ,function: participatory_space_manifest.query_list.constantize.new(manifest: participatory_space_manifest)

          field participatory_space_manifest.name.to_s.singularize.camelize(:lower),
                participatory_space_manifest.query_type.constantize,
                null: true,
                description: "Finds a #{participatory_space_manifest.name.to_s.singularize}"
          # ,function: participatory_space_manifest.query_finder.constantize.new(manifest: participatory_space_manifest)
        end

        field :user, Core::AuthorInterface,
              null: true,
              description: "A participant (user or group) in the current organization"
        # , function: Core::UserEntityFinder.new

        field :users, [Core::AuthorInterface],
              null: true,
              description: "The participants (users or groups) for the current organization"
        # , function: Core::UserEntityList.new

        field :session, Core::SessionType, null: true, description: "Return's information about the logged in user"

        field :hashtags, [Core::HashtagType], null: false, description: "The hashtags for current organization" do
          argument :name, String, required: false, description: "The name of the hashtag"
        end

        field :metrics, [Decidim::Core::MetricType], null: true do
          argument :names, [GraphQL::Types::String], required: false, description: "The names of the metrics you want to retrieve"
          argument :space_type, GraphQL::Types::String, required: false, description: "The type of ParticipatorySpace you want to filter with"
          argument :space_id, GraphQL::Types::Int, required: false, description: "The ID of ParticipatorySpace you want to filter with"
        end

        def metrics(names:, space_type:, space_id:)
          manifests = if names.blank?
                        Decidim.metrics_registry.all
                      else
                        Decidim.metrics_registry.all.select do |manifest|
                          names.include?(manifest.metric_name.to_s)
                        end
                      end
          filters = {}
          if space_type.present? && space_id.present?
            filters[:participatory_space_type] = space_type
            filters[:participatory_space_id] = space_id
          end

          manifests.map do |manifest|
            Decidim::Core::MetricResolver.new(manifest.metric_name, context[:current_organization], filters)
          end
        end

        def hashtags(name:)
          Decidim::HashtagsResolver.new(context[:current_organization], name).hashtags
        end

        def session
          context[:current_user]
        end

        def component(id:)
          component = Decidim::Component.published.find_by(id: id)
          component&.organization == context[:current_organization] ? component : nil
        end

        def decidim
          Decidim
        end

        def organization
          context[:current_organization]
        end
      end
    end
  end
end
