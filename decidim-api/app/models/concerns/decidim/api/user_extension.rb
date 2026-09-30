# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Api
    # This concern adds the JWT authenticable strategy for the User models to
    # allow regular users to sign in through the API (if configured from the
    # system panel). Allows normal users to utilize the API e.g. through mobile
    # applications.
    module UserExtension
      extend ActiveSupport::Concern

      included do
        devise :jwt_authenticatable, jwt_revocation_strategy: Decidim::Api::JwtDenylist
      end
    end
  end
end
