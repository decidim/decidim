# frozen_string_literal: true

module Decidim
  module Core
    # This type represents the current user session.
    class SessionType < Decidim::Api::Types::BaseObject
      description "The current session"

      field :user, UserType, "The current user", null: true

      def user
        return unless object

        Decidim::PersonalUserPresenter.new(object)
      end
    end
  end
end
