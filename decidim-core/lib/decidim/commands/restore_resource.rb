# frozen_string_literal: true

module Decidim
  module Commands
    class RestoreResource < ::Decidim::Command
      # Initializes the command.
      #
      # @param resource [ActiveRecord::Base] the resource to restore.
      # @param current_user [Decidim::User] the current user.
      def initialize(resource, current_user)
        @resource = resource
        @current_user = current_user
      end

      # Restores the resource.
      #
      # Broadcasts :ok if successful, :invalid otherwise.
      def call
        return broadcast(:invalid) if invalid?

        restore_resource

        broadcast(:ok, resource)
      rescue Decidim::Commands::HookError, StandardError
        broadcast(:invalid)
      end

      protected

      attr_reader :resource, :current_user

      def invalid? = false

      def restore_resource
        Decidim.traceability.perform_action!(
          "restore",
          resource,
          current_user
        ) do
          resource.restore!
        end
      end
    end
  end
end
