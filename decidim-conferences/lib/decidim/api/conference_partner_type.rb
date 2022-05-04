# frozen_string_literal: true

module Decidim
  module Conferences
    # This type represents a conference.
    class ConferencePartnerType < Decidim::Api::Types::BaseObject
      description "A conference partner"

      field :id, GraphQL::Types::ID, "ID of the resource", null: false
      field :name, GraphQL::Types::String, "Partner name", null: true
      field :partner_type, GraphQL::Types::String, "Partner type", null: true
      field :weight, GraphQL::Types::Int, "Order of appearance in which it should be presented", null: true
      field :link, GraphQL::Types::String, "Relevant URL for this partner", null: true
      field :logo, GraphQL::Types::String, "Link to the partner's logo", null: true
      field :created_at, Decidim::Core::DateTimeType, "The time this partner was created", null: true
      field :updated_at, Decidim::Core::DateTimeType, "The time this partner was updated", null: true

      def logo
        object.attached_uploader(:logo).path
      end
    end
  end
end
