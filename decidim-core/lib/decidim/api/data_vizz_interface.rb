# frozen_string_literal: true

module Decidim
  module Core
    DataVizzInterface = GraphQL::InterfaceType.define do
      name "DataVizzInterface"
      description "The interface that all DataVizz data."

      # field :id, !types.ID, "The participatory space's unique ID"

      # field :title, !TranslatedFieldType, "The name of this participatory space."

      # field :components, types[ComponentInterface] do
      #   description "Lists the components this space contains."
      #
      #   resolve ->(participatory_space, _args, _ctx) {
      #             Decidim::Component.where(
      #               participatory_space: participatory_space
      #             ).published
      #           }
      # end

      # field :stats, types[Decidim::Core::StatisticType] do
      #   resolve ->(participatory_space, _args, _ctx) {
      #     published_components = Component.where(participatory_space: participatory_space).published
      #
      #     stats = Decidim.component_manifests.map do |component_manifest|
      #       component_manifest.stats.with_context(published_components).map { |name, data| [name, data] }.flatten
      #     end
      #
      #     stats.reject(&:empty?)
      #   }
      # end

      resolve_type ->(obj, _ctx) {  }
    end
  end
end
