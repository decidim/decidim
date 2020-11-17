# frozen_string_literal: true

module Decidim
  module Conferences
    # This type represents a conference.
    class ConferenceMediaLinkType < GraphQL::Schema::Object
      graphql_name "ConferenceMediaLink"
      description "A conference media link"
      implements Decidim::Core::TimestampsInterface

      field :id, ID, null: false, description: "Internal ID for this media link"
      field :title, Decidim::Core::TranslatedFieldType, null: true, description: "Title for this media link"
      field :link, String, null: true, description: "URL for this media link"
      field :date, Decidim::Core::DateType, null: true, description: "Relevant date for the media link"
      field :weight, Int, null: true, description: "Order of appearance in which it should be presented"
    end
  end
end
