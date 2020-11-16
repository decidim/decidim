# frozen_string_literal: true

module Decidim
  module Conferences
    # This type represents a conference.
    ConferencePartnerType = GraphQL::ObjectType.define do
      name "ConferencePartner"
      description "A conference partner"

      implements Decidim::Core::TimestampsInterface

      field :id, !types.ID, "ID of the resource"
      field :name, types.String, "Partner name"
      field :partnerType, types.String, "Partner type", property: :partner_type
      field :weight, types.Int, "Order of appearance in which it should be presented"
      field :link, types.String, "Relevant URL for this partner"
      field :logo, types.String, "Link to the partner's logo"
    end
  end
end
