# frozen_string_literal: true

require "devise/strategies/authenticatable"

module Devise
  module Strategies
    class ApiAuthenticatable < Authenticatable
      def authenticate!
        key = authentication_hash[:key]
        secret = authentication_hash[:secret]

        resource = mapping.to.find_for_api_authentication(api_key: key)
        validation_status = validate(resource) { resource.valid_api_secret?(secret) }

        success!(resource) if validation_status
      end
    end
  end
end

Warden::Strategies.add(:api_authenticatable, Devise::Strategies::ApiAuthenticatable)
