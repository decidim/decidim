# frozen_string_literal: true

module Decidim
  module Admin
    # This command gets called when a component is created from the admin panel.
    class UpdateComponent < Rectify::Command
      attr_reader :form, :component, :previous_settings

      # Public: Initializes the command.
      #
      # form    - The form from which the data in this component comes from.
      # component - The component to update.
      def initialize(form, component)
        @manifest = component.manifest
        @form = form
        @component = component
      end

      # Public: Creates the Component.
      #
      # Broadcasts :ok if created, :invalid otherwise.
      def call
        return broadcast(:invalid) if form.invalid?

        transaction do
          update_component
          run_hooks
        end

        broadcast(:ok, settings_changed?, previous_settings, current_settings)
      end

      private

      def update_component
        @previous_settings = @component.attributes["settings"].dup

        @component.name = form.name
        @component.settings = form.settings
        @component.default_step_settings = form.default_step_settings
        @component.step_settings = form.step_settings
        @component.weight = form.weight

        @settings_changed = @component.settings_changed?

        @component.save!
      end

      def run_hooks
        @manifest.run_hooks(:update, @component)
      end

      def settings_changed?
        @settings_changed
      end

      def current_settings
        @component.attributes["settings"]
      end
    end
  end
end
