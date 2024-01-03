# frozen_string_literal: true

module Decidim
  module Commands
    class DestroyResource < ::Decidim::Command
      # Initializes the command.
      #
      # @param resource [ActiveRecord::Base] the resource to destroy.
      # @param current_user [Decidim::User] the current user.
      def initialize(resource, current_user)
        @resource = resource
        @current_user = current_user
      end

      # Destroys the result.
      #
      # Broadcasts :ok if successful, :invalid otherwise.
      def call
        return broadcast(:invalid) if invalid?

        run_before_hooks
        destroy_resource
        run_after_hooks

        broadcast(:ok, resource)
      rescue Decidim::Commands::HookError, StandardError
        broadcast(:invalid)
      end

      protected

      attr_reader :resource, :current_user

      def invalid? = false

      def destroy_resource
        Decidim.traceability.perform_action!(
          :delete,
          resource,
          current_user,
          **extra_params
        ) do
          resource.destroy!
        end
      end

      # Any extra params that you want to pass to the traceability service.
      #
      # @usage
      #  def extra_params = { "visibility" => "all"}
      #  def extra_params = { "visibility" => "public-only" }
      #  def extra_params = { "visibility" => "admin-only" }
      #  def extra_params
      #    {
      #      resource: {
      #        title: resource.title
      #      },
      #      participatory_space: {
      #        title: resource.participatory_space.title
      #      }
      #    }
      #  end
      #
      # @return [Hash] a hash with the extra params.
      def extra_params = {}

      # Useful for running any code that you may want to execute before deleting the resource.
      def run_before_hooks; end

      # Useful for running any code that you may want to execute after deleting the resource.
      def run_after_hooks; end
    end
  end
end
