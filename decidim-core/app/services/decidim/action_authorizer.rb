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
      raise AuthorizationError, "Missing data" unless feature && action

      return status(:ok) unless authorization_handler_name

      return status(:missing, handler: authorization_handler_name) unless authorization
      return status(:invalid, handler: authorization_handler_name, fields: unmatched_fields) if unmatched_fields.any?
      return status(:incomplete, handler: authorization_handler_name, fields: missing_fields) if missing_fields.any?

      status(:ok)
    end

    private

    def status(status_code, data = {})
      AuthorizationStatus.new(status_code, authorization_handler_name, data)
    end

    attr_reader :user, :feature, :action

    def authorization
      return nil unless user
      return nil unless permission["authorization_handler_name"]

      @authorization ||= user.authorizations.to_a.find do |authorization|
        authorization.name == permission.fetch("authorization_handler_name")
      end
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
      attr_reader :code, :handler_name, :data

      def initialize(code, handler_name, data)
        @code = code.to_sym
        @handler_name = handler_name
        @data = data.symbolize_keys
      end

      def ok?
        @code == :ok
      end
    end

    class AuthorizationError < StandardError; end
  end
end
