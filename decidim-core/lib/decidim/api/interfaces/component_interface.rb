# frozen_string_literal: true

module Decidim
  module Core
    module ComponentInterface
      include Decidim::Api::Types::BaseInterface

      description "This interface is implemented by all components that belong into a Participatory Space"

      implements Decidim::Core::TimestampsInterface

      field :id, ID, "The unique id of this component", null: false
      field :name, TranslatedFieldType, "The name of this component", null: false
      field :participatory_space, ParticipatorySpaceType, "The participatory space of this component", null: false
      field :published_at, Decidim::Core::DateTimeType, "The date and time this object was published", null: false
      field :url, String, "The URL of this component", null: false
      field :visible, GraphQL::Types::Boolean, "the visibility status of this component", null: true, method: :visible?
      field :weight, Integer, "The weight of this component", null: false

      def url
        Decidim::EngineRouter.main_proxy(object).root_url
      end

      def self.resolve_type(obj, _ctx)
        obj.manifest.query_type.constantize
      end
    end
  end
end
