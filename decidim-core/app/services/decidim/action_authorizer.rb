# frozen_string_literal: true

module Decidim
  # This class is used to authorize a user against an action in the context of a
  # feature.
  class ActionAuthorizer
    include Wisper::Publisher

    #
    # Initializes the ActionAuthorizer.
    #
    # user    - The user to authorize against.
    # feature - The feature to authenticate against.
    # action  - The action to authenticate.
    #
    def initialize(user, feature, action)
      @user = user
      @feature = feature
      @action = action.to_s if action
    end

    #
    # Checks the status of the given authorization.
    #
    # Returns:
    #   :ok an empty hash                      - When there is no authorization handler related to the action.
    #   result of authorization handler check  - When there is an authorization handler related to the action. Check Decidim::Verifications::Hooks class docs.
    #
    def authorize
      raise AuthorizationError, "Missing data" unless feature && action

      status_code, data = if authorization_handler_name
                            authorization_handler.authorization_status(authorization, permission_options)
                          else
                            [:ok, {}]
                          end

      AuthorizationStatus.new(status_code, authorization_handler, data)
    end

    private

    attr_reader :user, :feature, :action

    def authorization
      return nil unless user && authorization_handler_name

      @authorization ||= Verifications::Authorizations.new(user: user, name: authorization_handler_name).first
    end

    def authorization_handler
      return unless authorization_handler_name

      @authorization_handler ||= Verifications::Adapter.from_element(authorization_handler_name)
    end

    def authorization_handler_name
      permission&.fetch("authorization_handler_name", nil)
    end

    def permission_options
      permission&.fetch("options", {})
    end

    def permission
      return nil unless feature && action

      @permission ||= feature.permissions&.fetch(action, nil)
    end

    class AuthorizationStatus
      attr_reader :code, :data

      def initialize(code, authorization_handler, data)
        @code = code.to_sym
        @authorization_handler = authorization_handler
        @data = data.symbolize_keys
      end

      def current_path(redirect_url: nil)
        return unless @authorization_handler

        if pending?
          @authorization_handler.resume_authorization_path(redirect_url: redirect_url)
        else
          @authorization_handler.root_path(redirect_url: redirect_url)
        end
      end

      def handler_name
        return unless @authorization_handler

        @authorization_handler.key
      end

      def ok?
        @code == :ok
      end

      def pending?
        @code == :pending
      end
    end

    class AuthorizationError < StandardError; end
  end
end
