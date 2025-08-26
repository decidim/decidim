# frozen_string_literal: true

module Decidim
  module Core
    class StaticPageTopicType < Decidim::Api::Types::BaseObject
      description "The current organization static page topics"

      field :id, GraphQL::Types::ID, "Internal ID for this static page topic", null: false
      field :title, Decidim::Core::TranslatedFieldType, "The title of this static page.", null: false
      field :description, Decidim::Core::TranslatedFieldType, "The description of this static page.", null: false
      field :show_in_footer, GraphQL::Types::Boolean, "Whether this static page should be shown in the footer.", null: false
    end
  end
end
