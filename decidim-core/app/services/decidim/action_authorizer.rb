# frozen_string_literal: true

module Decidim
  # This class is used to authorize a user against an action in the context of a
  # feature.
  class ActionAuthorizer
    include Wisper::Publisher

    # Initializes the ActionAuthorizer.
    #
    # user    - The user to authorize against.
    # feature - The feature to authenticate against.
    # action  - The action to authenticate.
    def initialize(user, feature, action)
      @user = user
      @feature = feature
      @action = action.to_s if action
    end

    # Public: Broadcasts different events given the status of the authentication.
    #
    # Broadcasts:
    #   failed       - When no valid authorization can be found.
    #   unauthorized - When an authorization was found, but didn't match the credentials.
    #   incomplete   - An authorization was found, but lacks some required fields. User
    #                  should re-authenticate.
    #
    # Returns nil.
    def authorize
      status_code, fields = *status_data

      status(status_code, fields || {})
    end

    private

    def status_data
      raise AuthorizationError, "Missing data" unless feature && action

      if !authorization_handler_name
        :ok
      elsif !authorization
        :missing
      elsif !authorization.granted?
        :pending
      elsif unmatched_fields.any?
        [:invalid, fields: unmatched_fields]
      elsif missing_fields.any?
        [:incomplete, fields: missing_fields]
      else
        :ok
      end
    end

    def status(status_code, data = {})
      AuthorizationStatus.new(status_code, authorization_handler_name, data)
    end

    attr_reader :user, :feature, :action

    def authorization
      return nil unless user

      handler = permission["authorization_handler_name"]
      return nil unless handler

      @authorization ||= Verifications::Authorizations.new(user: user, name: handler).first
    end

    def unmatched_fields
      (permission_options.keys & authorization.metadata.to_h.keys).each_with_object({}) do |field, unmatched|
        unmatched[field] = permission_options[field] if authorization.metadata[field] != permission_options[field]
        unmatched
      end
    end

    def missing_fields
      permission_options.keys.each_with_object([]) do |field, missing|
        missing << field if authorization.metadata[field].blank?
        missing
      end
    end

    def permission_options
      permission["options"] || {}
    end

    def authorization_handler_name
      permission&.fetch("authorization_handler_name", nil)
    end

    def permission
      return nil unless feature
      return nil unless action

      @permission ||= feature.permissions&.fetch(action, nil)
    end

    class AuthorizationStatus
      attr_reader :code, :data

      def initialize(code, handler_name, data)
        @code = code.to_sym
        @handler_name = handler_name
        @data = data.symbolize_keys
      end

      def auth_method
        return unless @handler_name

        @auth_method ||= Verifications::Adapter.from_element(@handler_name)
      end

      def current_path(redirect_url: nil)
        return unless auth_method

        if pending?
          auth_method.resume_authorization_path(redirect_url: redirect_url)
        else
          auth_method.root_path(redirect_url: redirect_url)
        end
      end

      def handler_name
        return unless auth_method

        auth_method.key
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
