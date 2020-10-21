# frozen_string_literal: true

module Decidim
  module Verifications
    class DefaultActionAuthorizer
      #
      # Initializes the DefaultActionAuthorizer class.
      #
      # authorization - The existing authorization record to be evaluated. Can be nil.
      # options       - A hash with options related only to the current authorization process.
      # component     - The component where the authorization is taking place.
      # resouce       - The resource where the authorization is taking place. Can be nil.
      #
      def initialize(authorization, options, component, resource)
        @authorization = authorization
        @options = options.deep_dup || {} # options hash is cloned to allow changes applied to it without risks
        @component = resource.try(:component) || component
        @resource = resource
      end

      #
      # Checks the status of the given authorization.
      #
      # Returns:
      #   first value    - A symbol describing the authorization status.
      #     ok                - When everything is OK and the user is correctly authorized.
      #     missing           - When no authorization can be found.
      #     expired           - The validity time for the given authorization has run out, and
      #                         needs to be re-validated.
      #     pending           - When an authorization was found, but is not complete (eg. is
      #                         waiting for admin manual confirmation).
      #     unauthorized      - When an authorization was found, but the value of some of its fields
      #                         is not the expected one (eg. the user is authorized for scope A,
      #                         but this action is only for users in scope B).
      #     incomplete        - An authorization was found, but lacks some required fields. User
      #                         should re-authenticate.
      #   last value     - A hash with information to be shown to the users.
      #     action            - Translation key to be used in the "authorize" button. A close button will be shown is missing.
      #     cancel            - If present and true a cancel button will be shown.
      #     fields            - Wrong fields to be shown. It could be a list of names or a hash with names a current values.
      #     extra_explanation - Hash with an additional key and params to be translated and shown to the user.
      #
      def authorize
        if !authorization
          [:missing, { action: :authorize }]
        elsif authorization_expired?
          [:expired, { action: :authorize }]
        elsif !authorization.granted?
          [:pending, { action: :resume }]
        elsif unmatched_fields.any?
          [:unauthorized, { fields: unmatched_fields }]
        elsif missing_fields.any?
          [:incomplete, { fields: missing_fields, action: :reauthorize, cancel: true }]
        else
          [:ok, {}]
        end
      end

      #
      # Allow to add params to redirect URLs, to modify forms behaviour based on the authorization process options.
      #
      # Returns a hash with keys added to redirect URLs.
      #
      def redirect_params
        {}
      end

      protected

      attr_reader :authorization, :options, :component, :resource

      def unmatched_fields
        @unmatched_fields ||= (valued_options_keys & authorization.metadata.to_h.keys).each_with_object({}) do |field, unmatched|
          required_value = options[field].respond_to?(:value) ? options[field].value : options[field]
          unmatched[field] = required_value if authorization.metadata[field] != required_value
          unmatched
        end
      end

      def missing_fields
        @missing_fields ||= valid_options_keys.each_with_object([]) do |field, missing|
          missing << field if authorization.metadata[field].blank?
          missing
        end
      end

      def valid_options_keys
        @valid_options_keys ||= options.map do |key, value|
          key if value.present? || value.try(:required_for_authorization?)
        end.compact
      end

      def valued_options_keys
        @valued_options_keys ||= options.map do |key, value|
          key if value.respond_to?(:value) ? value.value.present? : value.present?
        end.compact
      end

      def authorization_expired?
        authorization.expires_at.present? && authorization.expired?
      end
    end
  end
end
