# frozen_string_literal: true

module Decidim
  module Commands
    class UpdateResource < ::Decidim::Command
      include Decidim::Commands::ResourceHandler

      # Initializes the command.
      #
      # @param form [Decidim::Form] the form object to update the resource.
      # @param resource [Decidim::Resource] the resource to update.
      def initialize(form, resource)
        @form = form
        @resource = resource
      end

      # Updates the resource if valid.
      #
      # Broadcasts :ok if successful, :invalid otherwise.
      def call
        return broadcast(:invalid) if invalid?

        perform!
        broadcast(:ok, resource)
      rescue ActiveRecord::RecordInvalid
        add_file_attribute_errors!
        broadcast(:invalid)
      rescue Decidim::Commands::HookError
        broadcast(:invalid)
      end

      protected

      attr_reader :form, :resource

      delegate :current_user, to: :form

      def update_resource
        Decidim.traceability.update!(
          resource,
          current_user,
          attributes,
          **extra_params
        )
      end

      # Useful for running any code that you may want to execute before updating the resource.
      def run_before_hooks; end

      # Useful for running any code that you may want to execute after updating the resource.
      def run_after_hooks; end

      private

      def perform!
        transaction do
          run_before_hooks
          update_resource
          run_after_hooks
        end
      end
    end
  end
end
