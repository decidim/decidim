# frozen_string_literal: true

module Decidim
  module Conferences
    # This type represents a registration type
    class ConferenceRegistrationTypeType < Decidim::Api::Types::BaseObject
      implements Decidim::Core::TimestampsInterface

      description "A conference registration type"

      field :description, Decidim::Core::TranslatedFieldType, "The description of this registration type.", null: true
      field :id, GraphQL::Types::ID, "Internal ID of the registration type.", null: false
      field :price, GraphQL::Types::Float, "The budget amount for this project", null: true
      field :published_at, Decidim::Core::DateTimeType, "The time this conference was published", null: true
      field :title, Decidim::Core::TranslatedFieldType, "The title of this registration type.", null: false
      field :weight, GraphQL::Types::Int, "The weight for this object", null: false

      def self.authorized?(object, context)
        chain = [
          allowed_to?(:list, :registration_types, object, context),
          object.visible?
        ].all?

        super && chain
      rescue Decidim::PermissionAction::PermissionNotSetError
        false
      end
    end
  end
end
