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

      # Updates the timeline_entry if valid.
      #
      # Broadcasts :ok if successful, :invalid otherwise.
      def call
        return broadcast(:invalid) if invalid?

        transaction do
          run_before_hooks
          update_resource
          run_after_hooks
        end

        broadcast(:ok, resource)
      rescue Decidim::Commands::HookError, ActiveRecord::ActiveRecordError
        broadcast(:invalid)
      end

      protected

      attr_reader :form, :resource

      def update_resource
        Decidim.traceability.update!(
          resource,
          form.current_user,
          attributes,
          **extra_params
        )
      end

      # Runs any before hooks. That you may want to execute before updating the resource.
      def run_before_hooks; end

      # Runs any after hooks. That you may want to execute after updating the resource.
      def run_after_hooks; end
    end
  end
end
