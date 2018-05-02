# frozen_string_literal: true

module Decidim
  module Admin
    # This form handles permissions for a particular action in the admin panel.
    class PermissionForm < Form
      attribute :authorization_handler_name, String
      attribute :options, Hash

      def manifest
        Decidim::Verifications.find_workflow_manifest(authorization_handler_name)
      end

      def options_schema
        @options_schema ||= options_manifest.schema.new(options || {})
      end

      def options_attributes
        options_manifest.attributes
      end

      private

      def options_manifest
        manifest.options
      end
    end
  end
end
