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
    def self.included(type)

      type.field :participatory_processes,
                 [Decidim::ParticipatoryProcesses::ParticipatoryProcessType],
                 null: false,
                 description: "Lists all participatory_processes" do
        argument :filter, Decidim::ParticipatoryProcesses::ParticipatoryProcessInputFilter, "This argument let's you filter the results", required: false
        argument :order, Decidim::ParticipatoryProcesses::ParticipatoryProcessInputSort, "This argument let's you order the results", required: false
      end

      def participatory_processes(args: {})
        manifest = Decidim.participatory_space_manifests.select {|m| m.name == :participatory_processes }.first
        Decidim::ParticipatoryProcesses::ParticipatoryProcessList.new(manifest: manifest).call(object, args, context)
      end

      type.field :participatory_process,
                 Decidim::ParticipatoryProcesses::ParticipatoryProcessType,
                 null: false,
                 description: "Finds a participatory_process" do
        argument :slug, String, "The slug of the participatory process", required: true

      end

      def participatory_process(slug:)
        manifest = Decidim.participatory_space_manifests.select {|m| m.name == :participatory_processes }.first
        Decidim::ParticipatoryProcesses::ParticipatoryProcessFinder.new(manifest: manifest).call(object, {slug: slug}, context)
      end

      type.field :assemblies,
                 [Decidim::Assemblies::AssemblyType],
                 null: false,
                 description: "Lists all assemblies" do

        argument :filter, Decidim::ParticipatoryProcesses::ParticipatoryProcessInputFilter, "This argument let's you filter the results", required: false
        argument :order, Decidim::ParticipatoryProcesses::ParticipatoryProcessInputSort, "This argument let's you order the results", required: false
      end

      def assemblies(args: {})
        manifest = Decidim.participatory_space_manifests.select {|m| m.name == :assemblies }.first
        Decidim::Core::ParticipatorySpaceList.new(manifest: manifest).call(object, args, context)
      end

      type.field :assembly,
                 Decidim::Assemblies::AssemblyType,
                 null: false,
                 description: "Finds a assembly" do
        argument :id, GraphQL::Types::ID, "The ID of the participatory space", required: true

      end

      def assembly(id: )
        manifest = Decidim.participatory_space_manifests.select {|m| m.name == :assemblies }.first
        Decidim::Core::ParticipatorySpaceFinder.new(manifest: manifest).call(object, {id: id}, context)
      end

      type.field :conferences,
                 [Decidim::Conferences::ConferenceType],
                 null: false,
                 description: "Lists all conferences" do

        argument :filter, Decidim::ParticipatoryProcesses::ParticipatoryProcessInputFilter, "This argument let's you filter the results", required: false
        argument :order, Decidim::ParticipatoryProcesses::ParticipatoryProcessInputSort, "This argument let's you order the results", required: false
      end

      def conferences(args: {})
        manifest = Decidim.participatory_space_manifests.select {|m| m.name == :conferences }.first

        Decidim::Core::ParticipatorySpaceList.new(manifest: manifest).call(object, args, context)
      end

      type.field :conference,
                 Decidim::Conferences::ConferenceType,
                 null: false,
                 description: "Finds a conference" do
        argument :id, GraphQL::Types::ID, "The ID of the participatory space", required: true

      end

      def conference(args: {})
        manifest = Decidim.participatory_space_manifests.select {|m| m.name == :conferences }.first

        Decidim::Core::ParticipatorySpaceFinder.new(manifest: manifest).call(object, args, context)
      end

      type.field :consultations,
                 [Decidim::Consultations::ConsultationType],
                 null: false,
                 description: "Lists all consultations" do

        argument :filter, Decidim::ParticipatoryProcesses::ParticipatoryProcessInputFilter, "This argument let's you filter the results", required: false
        argument :order, Decidim::ParticipatoryProcesses::ParticipatoryProcessInputSort, "This argument let's you order the results", required: false
      end

      def consultations(args: {})
        manifest = Decidim.participatory_space_manifests.select {|m| m.name == :consultations }.first

        Decidim::Core::ParticipatorySpaceList.new(manifest: manifest).call(object, args, context)
      end

      type.field :consultation,
                 Decidim::Consultations::ConsultationType,
                 null: false,
                 description: "Finds a consultation" do
        argument :id, GraphQL::Types::ID, "The ID of the participatory space", required: true

      end

      def consultation(args: {})
        manifest = Decidim.participatory_space_manifests.select {|m| m.name == :consultations }.first

        Decidim::Core::ParticipatorySpaceFinder.new(manifest: manifest).call(object, args, context)
      end

      type.field :initiatives,
                 [Decidim::Initiatives::InitiativeType],
                 null: false,
                 description: "Lists all initiatives" do

        argument :filter, Decidim::ParticipatoryProcesses::ParticipatoryProcessInputFilter, "This argument let's you filter the results", required: false
        argument :order, Decidim::ParticipatoryProcesses::ParticipatoryProcessInputSort, "This argument let's you order the results", required: false
      end

      def initiatives(args: {})
        manifest = Decidim.participatory_space_manifests.select {|m| m.name == :initiatives }.first
        Decidim::Core::ParticipatorySpaceList.new(manifest: manifest).call(object, args, context)
      end

      type.field :initiative,
                 Decidim::Initiatives::InitiativeType,
                 null: false,
                 description: "Finds a initiative" do
        argument :id, GraphQL::Types::ID, "The ID of the participatory space", required: true
      end

      def initiative(id:)
        manifest = Decidim.participatory_space_manifests.select {|m| m.name == :initiatives }.first

        Decidim::Core::ParticipatorySpaceFinder.new(manifest: manifest).call(object, {id: id}, context)
      end



      type.field :component, Decidim::Core::ComponentInterface, null: true do
        description "Lists the components this space contains."
        argument :id, GraphQL::Types::ID, required: true, description: "The ID of the component to be found"
      end

      def component(id: {})
        component = Decidim::Component.published.find_by(id: id)
        component&.organization == context[:current_organization] ? component : nil
      end

      type.field :session, Core::SessionType, description: "Return's information about the logged in user", null: true

      def session
        context[:current_user]
      end

      type.field :decidim, Core::DecidimType, "Decidim's framework properties.", null: true

      type.field :organization, Core::OrganizationType, "The current organization", null: true

      def organization
        context[:current_organization]
      end

      type.field :hashtags, [Core::HashtagType], null: true, description: "The hashtags for current organization"  do
        argument :name, GraphQL::Types::String, "The name of the hashtag", required: false
      end

      def hashtags(name: )
        Decidim::HashtagsResolver.new(context[:current_organization], name).hashtags
      end

      type.field :metrics,[Decidim::Core::MetricType], null: true do
        argument :names, [GraphQL::Types::String], "The names of the metrics you want to retrieve", required: false
        argument :space_type, GraphQL::Types::String, "The type of ParticipatorySpace you want to filter with", required: false
        argument :space_id, GraphQL::Types::Int, "The ID of ParticipatorySpace you want to filter with", required: false
      end

      def metrics(args: {})
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
      end

      type.field :user,
                 type: Core::AuthorInterface,  null: true,
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

      def user(args: {})
        Core::UserEntityFinder.new.call(object, args, context)
      end

      def users(args: {})
        Core::UserEntityList.new.call(object, args, context)
      end
    end
  end
end
