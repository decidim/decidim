# frozen_string_literal: true

module Decidim
  module Conferences
    # This type represents a conference.
    ConferencePartnerType = GraphQL::ObjectType.define do
      name "ConferencePartner"
      description "A conference partner"

      field :id, !types.ID, "ID of the resource"
      field :name, types.String, "Partner name"
      field :partnerType, types.String, "Partner type", property: :partner_type
      field :weight, types.Int, "Order of appearance in which it should be presented"
      field :link, types.String, "Relevant URL for this partner"
      field :logo, types.String, "Link to the partner's logo"
      field :createdAt, Decidim::Core::DateTimeType, "The time this partner was created", property: :created_at
      field :updatedAt, Decidim::Core::DateTimeType, "The time this partner was updated", property: :updated_at
    end
  end
end
