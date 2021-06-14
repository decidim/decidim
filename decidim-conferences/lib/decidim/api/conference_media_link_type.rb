# frozen_string_literal: true

module Decidim
  module Conferences
    # This type represents a conference.
    class ConferenceMediaLinkType < Decidim::Api::Types::BaseObject
      description "A conference media link"

      field :id, GraphQL::Types::ID, "Internal ID for this media link", null: false
      field :title, Decidim::Core::TranslatedFieldType, "Title for this media link", null: true
      field :link, GraphQL::Types::String, "URL for this media link", null: true
      field :date, Decidim::Core::DateType, "Relevant date for the media link", null: true
      field :weight, GraphQL::Types::Int, "Order of appearance in which it should be presented", null: true
      field :created_at, Decidim::Core::DateTimeType, "The time this entry was created", null: true
      field :updated_at, Decidim::Core::DateTimeType, "The time this entry was updated", null: true
    end
  end
end
