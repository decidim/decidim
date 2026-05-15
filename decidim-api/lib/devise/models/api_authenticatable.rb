# frozen_string_literal: true

module Devise
  module Models
    module ApiAuthenticatable
      extend ActiveSupport::Concern

      def api_secret=(new_secret)
        self.encrypted_password = ::Devise::Encryptor.digest(self.class, new_secret)
      end

      # Verifies whether a secret (ie from sign in) matches the user's secret.
      def valid_api_secret?(secret)
        Devise::Encryptor.compare(self.class, encrypted_password, secret)
      end

      module ClassMethods
        Devise::Models.config(self, :pepper, :stretches)

        def authentication_keys
          [:key, :secret]
        end

        def find_for_api_authentication(conditions)
          organization = conditions.dig(:env, "decidim.current_organization")
          return unless organization

          find_for_authentication(
            api_key: conditions[:api_key],
            decidim_organization_id: organization.id
          )
        end
      end
    end
  end
end
