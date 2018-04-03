# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Initiatives
    module ActionAuthorization
      extend ActiveSupport::Concern

      included do
        helper_method :action_authorization
      end

      # Public: Returns the authorization object for an authorization.
      #
      # action_name - The action to authorize against.
      #
      # Returns an AuthorizationStatus
      def action_authorization(action_name)
        return AuthorizationStatus.new(:ok) if can?(action_name.to_sym, Initiative)

        AuthorizationStatus.new(:denied)
      end

      class AuthorizationStatus
        attr_reader :code

        def initialize(code)
          @code = code.to_sym
        end

        def ok?
          @code == :ok
        end
      end
    end
  end
end
