# frozen_string_literal: true

module Decidim
  module Commands
    class SoftDeleteResource < ::Decidim::Command
      # Initializes the command.
      #
      # @param resource [ActiveRecord::Base] the resource to soft delete.
      # @param current_user [Decidim::User] the current user.
      def initialize(resource, current_user)
        @resource = resource
        @current_user = current_user
      end

      # Soft deletes the resource.
      #
      # Broadcasts :ok if successful, :invalid otherwise.
      def call
        return broadcast(:invalid) if invalid?

        run_before_hooks
        soft_delete_resource
        enqueue_soft_delete_job_for_associated_objects
        run_after_hooks

        broadcast(:ok, resource)
      rescue Decidim::Commands::HookError, StandardError
        broadcast(:invalid)
      end

      protected

      attr_reader :resource, :current_user

      def invalid? = false

      def soft_delete_resource
        Decidim.traceability.perform_action!(
          "soft_delete",
          resource,
          current_user,
          **extra_params
        ) do
          resource.trash!
        end
      end

      def enqueue_soft_delete_job_for_associated_objects
        Decidim::SoftDeleteAssociatedResourcesJob.perform_later(resource.id, resource.class.to_s, current_user.id)
      end

      # Any extra params that you want to pass to the traceability service.
      def extra_params = {}

      # Useful for running any code that you may want to execute before soft deleting the resource.
      def run_before_hooks; end

      # Useful for running any code that you may want to execute after soft deleting the resource.
      def run_after_hooks; end
    end
  end
end
