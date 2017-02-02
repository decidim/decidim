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
      raise AuthorizationError, "Missing data" unless feature && action && user

      return success unless authorization_handler_name
      return failure(:missing, authorization_handler_name) unless authorization
      return failure(:invalid, authorization_handler_name, unmatched_fields) if unmatched_fields.any?
      return failure(:incomplete, authorization_handler_name, missing_fields) if missing_fields.any?

      success
    end

    private

    def success
      broadcast(:ok)
    end

    def failure(status, *arguments)
      broadcast(status, *arguments)
    end

    attr_reader :user, :feature, :action

    def authorization
      return nil unless user
      return nil unless permission["authorization_handler_name"]

      @authorization ||= user.authorizations.find_by(
        name: permission.fetch("authorization_handler_name")
      )
    end

    def unmatched_fields
      (permission_options.keys & authorization.metadata.to_h.keys).each_with_object([]) do |field, unmatched|
        unmatched << field if authorization.metadata[field] != permission_options[field]
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
      permission.fetch("authorization_handler_name")
    end

    def permission
      return nil unless feature
      return nil unless action

      @permission ||= feature.permissions&.fetch(action, nil)
    end

    class AuthorizationResponse
      attr_reader :status
      attr_reader :data

      def initialize(status, data)
        @status = status.to_s
        @data = data.symbolize_keys
      end

      def ok?
        @status == "ok"
      end
    end

    class AuthorizationError < StandardError; end
  end
end
