# frozen_string_literal: true

module Decidim
  module Core
    ParticipatorySpaceInterface = GraphQL::InterfaceType.define do
      name "ParticipatorySpaceInterface"
      description "The interface that all participatory spaces should implement."

      field :id, !types.ID, "The participatory space's unique ID"

      field :title, !TranslatedFieldType, "The name of this participatory space."

      field :type, !types.String do
        description "The participatory space class name. i.e. Decidim::ParticipatoryProcess"
        resolve ->(participatory_space, _args, _ctx) {
          participatory_space.class.name
        }
      end

      field :components,
            type: types[ComponentInterface],
            description: "Lists the components this space contains.",
            function: ComponentListHelper.new

      field :stats, types[Decidim::Core::StatisticType] do
        resolve ->(participatory_space, _args, _ctx) {
          published_components = Component.where(participatory_space: participatory_space).published

          stats = Decidim.component_manifests.map do |component_manifest|
            component_manifest.stats.with_context(published_components).map { |name, data| [name, data] }.flatten
          end

          stats.reject(&:empty?)
        }
      end

      resolve_type ->(obj, _ctx) { obj.manifest.query_type.constantize }
    end

    class ComponentListHelper < ComponentList
      argument :order, ComponentInputSort, "Provides several methods to order the results"
      argument :filter, ComponentInputFilter, "Provides several methods to filter the results"
    end
  end
end
