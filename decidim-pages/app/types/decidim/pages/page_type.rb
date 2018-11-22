# frozen_string_literal: true

module Decidim
  module Pages
    PageType = GraphQL::ObjectType.define do
      name "Page"
      description "A page"

      field :id, !types.ID
      field :title, !Decidim::Core::TranslatedFieldType, "The title of this page (same as the component name)."
      field :body, Decidim::Core::TranslatedFieldType, "The body of this page."
      field :createdAt, !Decidim::Core::DateTimeType, "The time this page was created", property: :created_at
      field :updatedAt, !Decidim::Core::DateTimeType, "The time this page was updated", property: :updated_at
    end
  end
end
