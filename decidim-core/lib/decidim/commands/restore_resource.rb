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

        run_before_hooks
        restore_resource
        run_after_hooks

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
          current_user,
          **extra_params
        ) do
          resource.restore!
        end
      end

      # Any extra params that you want to pass to the traceability service.
      def extra_params = {}

      # Useful for running any code that you may want to execute before restoring the resource.
      def run_before_hooks; end

      # Useful for running any code that you may want to execute after restoring the resource.
      def run_after_hooks; end
    end
  end
end
