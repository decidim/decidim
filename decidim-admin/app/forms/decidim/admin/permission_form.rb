# frozen_string_literal: true

module Decidim
  module Admin
    # This form handles permissions for a particular action in the admin panel.
    class PermissionForm < Form
      attribute :authorization_handlers, Array[String]
      attribute(:authorization_handlers_options, { String => Object })

      def authorization_handlers
        handlers = super || []

        handlers.index_with { |name| { "options" => authorization_handler_options(name) } }
      end

      def authorization_handlers_names
        authorization_handlers.keys.map(&:to_s)
      end

      def authorization_handler_options(handler_name)
        authorization_handlers_options&.dig(handler_name.to_s) || {}
      end

      def manifest(handler_name)
        Decidim::Verifications.find_workflow_manifest(handler_name)
      end

      def options_schema(handler_name)
        options_manifest(handler_name).schema.new(authorization_handler_options(handler_name))
      end

      def options_attributes(handler_name)
        manifest = options_manifest(handler_name)
        manifest ? manifest.attributes : []
      end

      private

      def options_manifest(handler_name)
        manifest(handler_name).options
      end
    end
  end
end
