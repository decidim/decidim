# frozen_string_literal: true

module Decidim
  module Admin
    # This command gets called when a component is created from the admin panel.
    class CreateComponent < Rectify::Command
      attr_reader :form, :manifest, :participatory_space

      # Public: Initializes the command.
      #
      # manifest            - The component's manifest to create a component from.
      # form                - The form from which the data in this component comes from.
      # participatory_space - The participatory space that will hold this component.
      def initialize(manifest, form, participatory_space)
        @manifest = manifest
        @form = form
        @participatory_space = participatory_space
      end

      # Public: Creates the Component.
      #
      # Broadcasts :ok if created, :invalid otherwise.
      def call
        return broadcast(:invalid) if form.invalid?

        transaction do
          create_component
          run_hooks
        end

        broadcast(:ok)
      end

      private

      def create_component
        @component = Decidim.traceability.create!(
          Component,
          form.current_user,
          manifest_name: manifest.name,
          name: form.name,
          participatory_space: participatory_space,
          weight: form.weight,
          settings: form.settings,
          default_step_settings: form.default_step_settings,
          step_settings: form.step_settings
        )
      end

      def run_hooks
        manifest.run_hooks(:create, @component)
      end
    end
  end
end
