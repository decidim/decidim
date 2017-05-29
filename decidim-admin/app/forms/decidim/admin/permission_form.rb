# frozen_string_literal: true

module Decidim
  module Admin
    # This form handles permissions for a particular action in the admin panel.
    class PermissionForm < Form
      attribute :authorization_handler_name, String
      attribute :options, String

      validate :sanitize
      validate :options_is_valid_json

      private

      def sanitize
        self.authorization_handler_name = nil if authorization_handler_name.blank?
        self.options = nil if authorization_handler_name.blank?
        self.options = nil if options.blank?
      end

      def options_is_valid_json
        return unless options

        result = JSON.parse(options)
        errors.add(:options, :invalid_json) unless result.is_a?(Hash)
        result
      rescue JSON::ParserError
        errors.add(:options, :invalid_json)
      end
    end
  end
end
