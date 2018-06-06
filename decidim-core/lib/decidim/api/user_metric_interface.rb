# frozen_string_literal: true

module Decidim
  module Core
    UserMetricInterface = GraphQL::InterfaceType.define do
      name "UserMetricInterface"
      description "UserMetricInterface"

      # field :name, !types.String, "The author's name"

      # field :id, !types.ID, "The participatory space's unique ID"

      # field :title, !TranslatedFieldType, "The name of this participatory space."

      # field :users, types[AuthorInterface] do
      #   description "Lists the components this space contains."
      #
      #   resolve ->(_, _args, _ctx) {
      #             Decidim::User.all
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

      # resolve_type ->(obj, _ctx) {
      #                return Decidim::Core::UserType if obj.is_a? Decidim::User
      #                return Decidim::Core::UserGroupType if obj.is_a? Decidim::UserGroup
      #              }

      resolve_type ->(obj, _ctx) { obj.manifest.query_type.constantize }
    end
  end
end
