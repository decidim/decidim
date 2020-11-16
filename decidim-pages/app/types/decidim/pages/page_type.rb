# frozen_string_literal: true

module Decidim
  module Pages
    class PageType < GraphQL::Schema::Object
      graphql_name "Page"
      description "A page"

      field :id,ID, null: false
      field :title, Decidim::Core::TranslatedFieldType, null: false, description: "The title of this page (same as the component name)."
      field :body, Decidim::Core::TranslatedFieldType, null: true , description: "The body of this page."
      field :createdAt, Decidim::Core::DateTimeType, null: false ,  description: "The time this page was created"
      field :updatedAt, Decidim::Core::DateTimeType, null: false ,  description: "The time this page was updated"

      def createdAt
        object.created_at
      end
      def updatedAt
        object.updated_at
      end
    end
  end
end
