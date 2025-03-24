# frozen_string_literal: true

module Decidim
  module Conferences
    # This type represents a conference.
    class ConferenceMediaLinkType < Decidim::Api::Types::BaseObject
      implements Decidim::Core::TimestampsInterface

      description "A conference media link"

      field :date, Decidim::Core::DateType, "Relevant date for the media link", null: true
      field :id, GraphQL::Types::ID, "Internal ID for this media link", null: false
      field :link, GraphQL::Types::String, "URL for this media link", null: true
      field :title, Decidim::Core::TranslatedFieldType, "Title for this media link", null: true
      field :weight, GraphQL::Types::Int, "Order of appearance in which it should be presented", null: true
    end
  end
end
