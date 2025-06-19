# frozen_string_literal: true

module Decidim
  module Core
    class ParticipantDetailsType < Decidim::Api::Types::BaseObject
      description "details of a participant"

      field :email, GraphQL::Types::String, "The user's email", null: false
      field :name, GraphQL::Types::String, "The user's name", null: false
      field :nickname, GraphQL::Types::String, "The user's nickname", null: false

      def self.authorized?(object, context)
        super && allowed_to?(:read, :admin_dashboard, object, context, scope: :admin)
      end
    end
  end
end
