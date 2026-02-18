# frozen_string_literal: true

module Warden
  module JWTAuth
    # This module adds some overrides to Warde::JWTAuth due to some issues with
    # how it needs to be setup.
    module EnvHelper
      # Returns ORIGINAL_FULLPATH, REQUEST_PATH or REQUEST_URI environment
      # variable, which is different from the original version returning the
      # PATH_INFO environment variable.
      #
      # This is overridden because the `PATH_INFO` string only includes the
      # route under the engine where it is defined, i.e. `/sign_in` and
      # `/sign_out` which are defined under the `Decidim::Api`.
      #
      # Instead, we want this method to return the full path, i.e.
      # `/api/sign_in` and `/api/sign_out` in order to map these routes
      # correctly as the JWT token dispatch and revocation routes. Otherwise the
      # token would be dispatched and revoked also with normal user sign in and
      # sign out requests under the `Decidim::Core` engine which we do not want.
      #
      # This affects the Devise::JWT / Warden::JWTAuth configuration that is
      # defined at `decidim-api/config/initializers/devise.rb` (as
      # `config.jwt`).
      #
      # The return value is only used by Warden::JWTAuth to check when the token
      # should be dispatched or revoked for the user, nothing else.
      #
      # Note that this behaves slightly differently during controller testing
      # and when the application is actually running under Rack. The end result
      # is the same but some of the environment variables may be missing during
      # controller testing (e.g. `REQUEST_PATH` is not defined under that
      # situation).
      #
      # @param env [Hash] Rack env
      # @return [String]
      def self.path_info(env)
        env["ORIGINAL_FULLPATH"] || env["REQUEST_PATH"] || env["REQUEST_URI"] || ""
      end
    end
  end
end
