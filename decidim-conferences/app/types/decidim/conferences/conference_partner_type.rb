# frozen_string_literal: true

module Decidim
  module Conferences
    # This type represents a conference.
    class ConferencePartnerType < GraphQL::Schema::Object
      graphql_name "ConferencePartner"
      description "A conference partner"

      implements Decidim::Core::TimestampsInterface

      field :id, ID, null: false, description: "ID of the resource"
      field :name, String, null: true, description: "Partner name"
      field :partnerType, String, null: true, description: "Partner type" do
        def resolve(object:, arguments:, context:)
          object.partner_type
        end
      end
      field :weight, Int, null: true, description: "Order of appearance in which it should be presented"
      field :link, String, null: true, description: "Relevant URL for this partner"
      field :logo, String, null: true, description: "Link to the partner's logo"
    end
  end
end
