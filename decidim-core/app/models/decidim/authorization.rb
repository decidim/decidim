# frozen_string_literal: true

module Decidim
  # An authorization is a record that a User has been authorized somehow. Other
  # models in the system can use different kind of authorizations to allow a
  # user to perform actions.
  #
  # To create an authorization for a user we need to use an
  # AuthorizationHandler that validates the user against a set of rules. An
  # example could be a handler that validates a user email against an API and
  # depending on the response it allows the creation of the authorization or
  # not.
  class Authorization < ApplicationRecord
    belongs_to :user, foreign_key: "decidim_user_id", class_name: "Decidim::User"

    validates :name, uniqueness: { scope: :decidim_user_id }

    validate :active_handler?

    private

    def active_handler?
      AuthorizationHandler.active_handler?(name)
    end
  end
end
