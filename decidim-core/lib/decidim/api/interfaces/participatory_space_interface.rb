# frozen_string_literal: true

module Decidim
  module Core
    module ParticipatorySpaceInterface
      include Decidim::Api::Types::BaseInterface
      graphql_name "ParticipatorySpaceInterface"
      description "The interface that all participatory spaces should implement."

      field :id, GraphQL::Types::ID, "The participatory space's unique ID", null: false

      field :title, TranslatedFieldType, "The graphql_name of this participatory space.", null: false

      field :type, String, description: "The participatory space class name. i.e. Decidim::ParticipatoryProcess", null: false

      def type
        object.class.name
      end

      field :components, [ComponentInterface], null: true, description: "Lists the components this space contains." do
        argument :filter, ComponentInputFilter, "Provides several methods to filter the results", required: false
        argument :order, ComponentInputSort, "Provides several methods to order the results", required: false
      end

      def components(filter: {}, order: {})
        ComponentList.new.call(object, { filter:, order: }, context)
      end

      field :stats, [Decidim::Core::StatisticType, { null: true }], null: true

      def stats
        return if object.respond_to?(:show_statistics) && !object.show_statistics

        published_components = Component.where(participatory_space: object).published

        stats = Decidim.component_manifests.map do |component_manifest|
          component_manifest.stats.with_context(published_components).map { |name, data| [name, data] }.flatten
        end

        stats.reject(&:empty?)
      end

      def self.resolve_type(obj, _ctx)
        obj.manifest.query_type.constantize
      end
    end
  end
end
