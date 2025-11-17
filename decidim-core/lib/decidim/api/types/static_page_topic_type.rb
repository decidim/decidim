# frozen_string_literal: true

module Decidim
  module Core
    # This type represents a topic's page
    class StaticPageTopicType < Decidim::Api::Types::BaseObject
      description "The current organization static page topics"

      field :description, Decidim::Core::TranslatedFieldType, "The description of this static page topic", null: false
      field :id, GraphQL::Types::ID, "Internal ID of this static page topic", null: false
      field :show_in_footer, GraphQL::Types::Boolean, "Whether this static page topic should be shown in the footer", null: false
      field :static_pages, [Decidim::Core::StaticPageType, { null: true }], "The static pages associated to this static page topic", null: true, method: :pages
      field :title, Decidim::Core::TranslatedFieldType, "The title of this static page topic", null: false
    end
  end
end
