# frozen_string_literal: true

module Decidim
  # This class is used to authorize a user against an action in the context of a
  # component.
  class ActionAuthorizer
    #
    # Initializes the ActionAuthorizer.
    #
    # user      - The user to authorize against.
    # action    - The action to authenticate.
    # component - The component to authenticate against.
    # resource  - The resource to authenticate against. Can be nil.
    #
    def initialize(user, action, component, resource)
      @user = user
      @action = action.to_s if action
      @component = resource.try(:component) || component
      @resource = resource
    end

    #
    # Authorize user to perform an action in the context of a component.
    #
    # Returns:
    #   :ok an empty hash                      - When there is no authorization handler related to the action.
    #   result of authorization handler check  - When there is an authorization handler related to the action. Check Decidim::Verifications::DefaultActionAuthorizer class docs.
    #
    def authorize
      raise AuthorizationError, "Missing data" unless component && action

      AuthorizationStatusCollection.new(authorization_handlers, user, component, resource)
    end

    private

    attr_reader :user, :component, :resource, :action

    def authorization_handlers
      available_authorizations = component.organization.available_authorizations
      if permission&.has_key?("authorization_handler_name") && available_authorizations.include?(permission["authorization_handler_name"])
        options = permission["options"]
        { permission["authorization_handler_name"] => options.present? ? { "options" => options } : {} }
      else
        permission&.fetch("authorization_handlers", {})&.slice(*available_authorizations)
      end
    end

    def permission
      return nil unless component && action

      @permission ||= resource&.permissions&.fetch(action, nil) || component.permissions&.fetch(action, nil)
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
          @authorization_handler.resume_authorization_path(redirect_url:)
        else
          @authorization_handler.root_path(redirect_url:)
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

      def unauthorized?
        @code == :unauthorized
      end

      def ephemeral?
        @authorization_handler.ephemeral?
      end
    end

    class AuthorizationStatusCollection
      attr_reader :statuses

      def initialize(authorization_handlers, user, component, resource)
        @ephemeral_user = user&.ephemeral?
        @authorization_handlers = authorization_handlers
        @statuses = authorization_handlers&.filter_map do |name, opts|
          handler = Verifications::Adapter.from_element(name)
          next if @ephemeral_user && !handler.ephemeral?

          authorization = user ? Verifications::Authorizations.new(organization: user.organization, user:, name:).first : nil
          status_code, data = handler.authorize(authorization, opts["options"], component, resource)
          AuthorizationStatus.new(status_code, handler, data)
        end || []
      end

      def ok?
        # When no statuses are present for the action ephemeral users
        # are not allowed to perform the action
        return !@ephemeral_user if statuses.blank?

        statuses.all?(&:ok?)
      end

      def global_code
        return :ok if ok?

        [:unauthorized, :pending].each do |code|
          return code if statuses.any? { |status| status.code == code }
        end

        false
      end

      def status_for(handler_name)
        statuses.find { |status| status.handler_name == handler_name }
      end

      def codes
        @codes ||= statuses.map(&:code)
      end

      def pending_authorizations_count
        return 0 if @statuses.blank?

        @statuses.count
      end

      def single_authorization_required?
        pending_authorizations_count == 1 && [:ok, :unauthorized].exclude?(global_code)
      end

      def ephemeral?
        return if statuses.blank?

        statuses.all?(&:ephemeral?)
      end

      def user_pending?
        !global_code && statuses.any? { |status| [:missing, :expired, :incomplete].include?(status.code) }
      end
    end

    class AuthorizationError < StandardError; end
  end
end
