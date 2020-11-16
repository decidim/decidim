# frozen_string_literal: true

module Decidim
  module Conferences
    # This type represents a conference.
    ConferenceMediaLinkType = GraphQL::ObjectType.define do
      name "ConferenceMediaLink"
      description "A conference media link"
      implements Decidim::Core::TimestampsInterface

      field :id, !types.ID, "Internal ID for this media link"
      field :title, Decidim::Core::TranslatedFieldType, "Title for this media link"
      field :link, types.String, "URL for this media link"
      field :date, Decidim::Core::DateType, "Relevant date for the media link"
      field :weight, types.Int, "Order of appearance in which it should be presented"
    end
  end
end
