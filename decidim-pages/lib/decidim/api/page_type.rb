# frozen_string_literal: true

module Decidim
  module Pages
    class PageType < Decidim::Api::Types::BaseObject
      implements Decidim::Core::TimestampsInterface

      description "A page"

      field :body, Decidim::Core::TranslatedFieldType, "The body of this page.", null: true
      field :id, GraphQL::Types::ID, "The Id of the page", null: false
      field :title, Decidim::Core::TranslatedFieldType, "The title of this page (same as the component name).", null: false
    end
  end
end
