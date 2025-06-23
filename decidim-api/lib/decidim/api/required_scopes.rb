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

        def determine_required_scopes
          return @required_scopes if @required_scopes.present?
          return unless superclass.respond_to?(:determine_required_scopes)

          superclass.determine_required_scopes
        end

        def scope_authorized?(context)
          req_scopes = determine_required_scopes
          return true unless req_scopes.is_a?(Array)

          scopes = context[:scopes] # ::Doorkeeper::OAuth::Scopes
          scopes.scopes?(req_scopes)
        end
      end
    end
  end
end
