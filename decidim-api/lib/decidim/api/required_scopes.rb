# frozen_string_literal: true

module Decidim
  module Api
    # Adds methods to the API objects for validating the API scopes.
    module RequiredScopes
      extend ActiveSupport::Concern

      class_methods do
        def required_scopes(*scopes)
          @required_scopes = scopes
        end

        def scope_authorized?(context)
          return true unless @required_scopes.is_a?(Array)

          scopes = context[:scopes] # ::Doorkeeper::OAuth::Scopes
          scopes.scopes?(@required_scopes)
        end
      end
    end
  end
end
