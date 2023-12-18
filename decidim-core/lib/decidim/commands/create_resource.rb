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

        transaction do
          run_before_hooks
          create_resource
          run_after_hooks
        end

        broadcast(:ok, resource)
      rescue Decidim::Commands::HookError, ActiveRecord::RecordInvalid
        file_field_names.each do |field|
          form.errors.add(field, resource.errors[field]) if resource.errors.include? field
        end

        broadcast(:invalid)
      end

      protected

      # @param soft [Boolean] whether to soft-create the resource or not.
      # @usage
      #  create_resource(soft: true) - Will soft-create the resource, returning any validation errors.
      #  create_resource - Will create the resource, raising any validation errors.
      def create_resource(soft: false)
        raise "Removing soft" if soft

        @resource = Decidim.traceability.create!(resource_class, current_user, attributes, **extra_params)
      end

      attr_reader :form, :resource

      delegate :current_user, to: :form

      # Useful for running any code that you may want to execute before creating the resource.
      def run_before_hooks; end

      # Useful for running any code that you may want to execute after creating the resource.
      def run_after_hooks; end
    end
  end
end
