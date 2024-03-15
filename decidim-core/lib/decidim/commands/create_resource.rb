# frozen_string_literal: true

module Decidim
  module Commands
    class CreateResource < ::Decidim::Command
      include Decidim::Commands::ResourceHandler

      # Initializes the command.
      # @param form [Decidim::Form] the form object to create the resource.
      def initialize(form)
        @form = form
      end

      # Creates the result if valid.
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

      # @usage
      #  create_resource - Will create the resource, raising any validation errors.
      def create_resource
        @resource = Decidim.traceability.send(create_method, resource_class, current_user, attributes, **extra_params)
        @resource.persisted? ? resource : raise(ActiveRecord::RecordInvalid, resource)
      end

      attr_reader :form, :resource

      delegate :current_user, to: :form

      def create_method
        has_file_attributes? ? :create : :create!
      end

      # Useful for running any code that you may want to execute before creating the resource.
      def run_before_hooks; end

      # Useful for running any code that you may want to execute after creating the resource.
      def run_after_hooks; end

      private

      def perform!
        transaction do
          run_before_hooks
          create_resource
          run_after_hooks
        end
      end
    end
  end
end
