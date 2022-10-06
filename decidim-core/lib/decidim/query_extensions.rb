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
    def self.included(type)
      type.field :participatory_processes,
                 [Decidim::ParticipatoryProcesses::ParticipatoryProcessType],
                 null: true,
                 description: "Lists all participatory_processes" do
        argument :filter, Decidim::ParticipatoryProcesses::ParticipatoryProcessInputFilter, "This argument let's you filter the results", required: false
        argument :order, Decidim::ParticipatoryProcesses::ParticipatoryProcessInputSort, "This argument let's you order the results", required: false
      end

      type.field :participatory_process,
                 Decidim::ParticipatoryProcesses::ParticipatoryProcessType,
                 null: true,
                 description: "Finds a participatory_process" do
        argument :id, GraphQL::Types::ID, "The ID of the participatory space", required: false
        argument :slug, String, "The slug of the participatory process", required: false
      end

      type.field :component, Decidim::Core::ComponentInterface, null: true do
        description "Lists the components this space contains."
        argument :id, GraphQL::Types::ID, required: true, description: "The ID of the component to be found"
      end

      type.field :session, Core::SessionType, description: "Return's information about the logged in user", null: true

      type.field :decidim, Core::DecidimType, "Decidim's framework properties.", null: true

      type.field :organization, Core::OrganizationType, "The current organization", null: true

      type.field :hashtags, [Core::HashtagType], null: true, description: "The hashtags for current organization" do
        argument :name, GraphQL::Types::String, "The name of the hashtag", required: false
      end

      type.field :metrics, type: [Decidim::Core::MetricType], null: true do
        argument :names, [GraphQL::Types::String], "The names of the metrics you want to retrieve", camelize: false, required: false
        argument :space_type, GraphQL::Types::String, "The type of ParticipatorySpace you want to filter with", camelize: false, required: false
        argument :space_id, GraphQL::Types::Int, "The ID of ParticipatorySpace you want to filter with", camelize: false, required: false
      end

      type.field :user,
                 type: Core::AuthorInterface, null: true,
                 description: "A participant (user or group) in the current organization" do
        argument :id, GraphQL::Types::ID, "The ID of the participant", required: false
        argument :nickname, GraphQL::Types::String, "The @nickname of the participant", required: false
      end

      type.field :users,
                 type: [Core::AuthorInterface], null: true,
                 description: "The participants (users or groups) for the current organization" do
        argument :order, Decidim::Core::UserEntityInputSort, "Provides several methods to order the results", required: false
        argument :filter, Decidim::Core::UserEntityInputFilter, "Provides several methods to filter the results", required: false
      end
    end

    def participatory_processes(filter: {}, order: {})
      manifest = Decidim.participatory_space_manifests.select { |m| m.name == :participatory_processes }.first
      Decidim::Core::ParticipatorySpaceListBase.new(manifest:).call(object, { filter:, order: }, context)
    end

    def participatory_process(id: nil, slug: nil)
      manifest = Decidim.participatory_space_manifests.select { |m| m.name == :participatory_processes }.first
      Decidim::Core::ParticipatorySpaceFinderBase.new(manifest:).call(object, { id:, slug: }, context)
    end

    def component(id: {})
      component = Decidim::Component.published.find_by(id:)
      component&.organization == context[:current_organization] ? component : nil
    end

    def session
      context[:current_user]
    end

    def decidim
      Decidim
    end

    def organization
      context[:current_organization]
    end

    def hashtags(name: nil)
      Decidim::HashtagsResolver.new(context[:current_organization], name).hashtags
    end

    def metrics(names: [], space_type: nil, space_id: nil)
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

    def user(id: nil, nickname: nil)
      Core::UserEntityFinder.new.call(object, { id:, nickname: }, context)
    end

    def users(filter: {}, order: {})
      Core::UserEntityList.new.call(object, { filter:, order: }, context)
    end
  end
end
