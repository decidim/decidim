# frozen_string_literal: true

module Decidim
  module Core
    # This type represents a page
    class StaticPageType < Decidim::Api::Types::BaseObject
      description "The current organization static pages"

      implements Decidim::Core::TimestampsInterface

      field :content, Decidim::Core::TranslatedFieldType, "The content of this page.", null: true
      field :id, GraphQL::Types::ID, "The id of the page", null: false
      field :title, Decidim::Core::TranslatedFieldType, "The title of this page.", null: false
      field :url, GraphQL::Types::String, "The URL for this page", null: false
      field :topic, Decidim::Core::StaticPageTopicType, "The topic of this page", null: true

      def url
        Decidim::EngineRouter.new("decidim", { host: context[:current_organization].host }).page_url(object)
      end
    end
  end
end
