# frozen_string_literal: true

module Decidim
  module Pages
    class PageType < Decidim::Api::Types::BaseObject
      implements Decidim::Core::TimestampsInterface

      description "A page"

      field :id, GraphQL::Types::ID, null: false
      field :title, Decidim::Core::TranslatedFieldType, "The title of this page (same as the component name).", null: false
      field :body, Decidim::Core::TranslatedFieldType, "The body of this page.", null: true
    end
  end
end
