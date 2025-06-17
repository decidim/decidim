# frozen_string_literal: true

module Decidim
  module Core
    class ParticipantDetailsType < Decidim::Core::UserType
      description "Details of a participant"

      field :email, GraphQL::Types::String, "The user's email", null: false
      field :name, GraphQL::Types::String, "The user's name", null: false
      field :nickname, GraphQL::Types::String, "The user's nickname", null: false

      def nickname
        enforce_permission_to :read, :users_statistics, user: current_user

        object.nickname
      end

      def name
        enforce_permission_to :read, :users_statistics, user: current_user

        object.name
      end

      def email
        enforce_permission_to :read, :users_statistics, user: current_user

        object.email
      end

      private

      def current_user
        context[:current_user]
      end
    end
  end
end
