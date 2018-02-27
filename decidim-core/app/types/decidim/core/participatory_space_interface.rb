# frozen_string_literal: true

module Decidim
  module Core
    ParticipatorySpaceInterface = GraphQL::InterfaceType.define do
      name "ParticipatorySpaceInterface"
      description "The interface that all participatory spaces should implement."

      field :id, !types.ID, "The participatory space's unique ID"

      field :title, !TranslatedFieldType, "The name of this participatory space."

      field :components, types[ComponentInterface] do
        description "Lists the components this space contains."

        resolve ->(participatory_space, _args, _ctx) {
                  Decidim::Feature.where(
                    participatory_space: participatory_space
                  ).published
                }
      end

      field :stats, types[Decidim::Core::StatisticType] do
        resolve ->(participatory_space, _args, _ctx) {
          published_features = Feature.where(participatory_space: participatory_space).published

          stats = Decidim.feature_manifests.map do |feature_manifest|
            feature_manifest.stats.with_context(published_features).map { |name, data| [name, data] }.flatten
          end

          stats.reject(&:empty?)
        }
      end

      resolve_type ->(obj, _ctx) { obj.manifest.query_type.constantize }
    end
  end
end
