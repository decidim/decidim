# frozen_string_literal: true

module Decidim
  module OAuth
    module TokenGenerator
      def self.generate(options = {})
        # For any request containing the `user` or `api:read` scope, generate a
        # JWT token that can be used to identify the user with the API through
        # Warden::JWTAuth. For the `api:write` scope, the `user` scope is
        # additionally always required in order to represent the user.
        #
        # Note that the `user` scope needs to match what is set at the
        # `devise_for` call because this needs to match the Devise/Warden scope
        # that the user is authenticated against.
        if %w(user api:read).any? { |scope| options[:scopes].exists?(scope) }
          # Note that warden-jwt_auth uses the `scp` claim to map the token to
          # the correct Warden scope, i.e. the one that `device_for` was called
          # for (e.g. `:user`). This is a limitation of the gem.
          #
          # The requested scopes are stored in the Doorkeeper's token stored
          # locally in the database which we can utilize later on when the user
          # is authenticated with the `Authorization` header.
          scp = options[:scopes].exists?("user") ? "user" : "anonymous"
          user = Decidim::User.find(options[:resource_owner_id])
          aud = options[:application][:uid]
          token, _payload = Warden::JWTAuth::UserEncoder.new.call(user, scp, aud)
          return token
        end

        # Default doorkeeper token generator
        ::Doorkeeper::OAuth::Helpers::UniqueToken.generate(options)
      end
    end
  end
end
