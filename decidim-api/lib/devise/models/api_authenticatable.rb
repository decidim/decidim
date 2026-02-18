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
          find_for_authentication(conditions)
        end
      end
    end
  end
end
