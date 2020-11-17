# frozen_string_literal: true

module Decidim
  module Core
    module ParticipatorySpaceInterface
      include GraphQL::Schema::Interface
      # name "ParticipatorySpaceInterface"
      # description "The interface that all participatory spaces should implement."

      field :id, GraphQL::Types::ID, null: false, description: "The participatory space's unique ID"

      field :title, TranslatedFieldType, null: false, description: "The name of this participatory space."

      field :type, String, null: false, description: "The participatory space class name. i.e. Decidim::ParticipatoryProcess" do
        def resolve(participatory_space, _args, _ctx)
          participatory_space.class.name
        end
      end

      field :components,
            type: [ComponentInterface],
            null: true,
            description: "Lists the components this space contains."
      # , function: Decidim::Core::ComponentListHelper.new

      field :stats, Decidim::Core::StatisticType, null: true do
        def resolve(participatory_space:, _args:, _ctx:)
          return if participatory_space.respond_to?(:show_statistics) && !participatory_space.show_statistics

          published_components = Component.where(participatory_space: participatory_space).published

          stats = Decidim.component_manifests.map do |component_manifest|
            component_manifest.stats.with_context(published_components).map { |name, data| [name, data] }.flatten
          end

          stats.reject(&:empty?)
        end
      end

      def resolve_type(object:, _ctx:)
        object.manifest.query_type.constantize
      end
    end

    class ComponentListHelper < ComponentList
      argument :order, ComponentInputSort, "Provides several methods to order the results"
      argument :filter, ComponentInputFilter, "Provides several methods to filter the results"
    end
  end
end
