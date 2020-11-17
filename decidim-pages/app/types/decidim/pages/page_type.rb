# frozen_string_literal: true

module Decidim
  module Pages
    class PageType < GraphQL::Schema::Object
      graphql_name "Page"
      description "A page"
      implements Decidim::Core::TimestampsInterface

      field :id, ID, null: false
      field :title, Decidim::Core::TranslatedFieldType, null: false, description: "The title of this page (same as the component name)."
      field :body, Decidim::Core::TranslatedFieldType, null: true, description: "The body of this page."
    end
  end
end
