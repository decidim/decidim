# frozen_string_literal: true

module Decidim
  module OAuth
    module TokenGenerator
      def self.generate(options = {})
        # For any request containing the `user` or `api:read` scope, generate a
        # JWT token that can be used to authorize the user with the API. For the
        # `api:write` scope, the `user` scope is additionally always required in
        # order to represent the user.
        #
        # Note that the `user` scope needs to match what is set at the
        # `devise_for` call because this needs to match the Devise/Warden scope
        # that the user is authenticated against.
        if %w(user api:read).any? { |scope| options[:scopes].exists?(scope) }
          # Note that warden-jwt_auth uses the `scp` claim to map the token to
          # the correct Warden scope, i.e. the one that `device_for` was called
          # for (e.g. `:user`). This is a limitation of the gem.
          #
          # We assign the token manually because otherwise all the requested
          # scopes would be part of the `scp` claim as defined by
          # warden-jwt_auth. This would break identifying the authenticated user
          # as the `scp` claim needs to match the Devise scope in order to
          # authenticate the user.
          #
          # The requested scopes are stored in the Doorkeeper's token stored
          # locally in the database which we can utilize later on when the user
          # is authenticated with the `Authorization` header.
          scp = options[:scopes].exists?("user") ? "user" : "anonymous"
          user = Decidim::User.find(options[:resource_owner_id])
          aud = options[:application][:uid]
          sub = user.jwt_subject
          payload = {
            "aud" => aud,
            "sub" => String(sub),
            "scp" => scp
          }

          return Warden::JWTAuth::TokenEncoder.new.call(payload)
        end

        # Default doorkeeper token generator
        ::Doorkeeper::OAuth::Helpers::UniqueToken.generate(options)
      end
    end
  end
end
