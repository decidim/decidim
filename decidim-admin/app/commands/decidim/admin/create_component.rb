# frozen_string_literal: true
module Decidim
  module Admin
    # This command gets called when a component is created from the admin panel.
    class CreateComponent < Rectify::Command
      attr_reader :manifest, :form, :feature, :step

      # Public: Initializes a component creation command.
      #
      # manifest - The component's manifest from which to create the component.
      # form     - The form from which to get the data from.
      # feature  - The participatory process in which to add the newly created
      #            component.
      def initialize(manifest, form, feature)
        @manifest = manifest
        @form = form
        @feature = feature
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

      attr_reader :form

      def create_component
        @component = Component.create!(
          component_type: manifest.name,
          name: form.name,
          feature: feature,
          step: step
        )
      end

      def run_hooks
        manifest.run_hooks(:create, @component)
      end

      def participatory_process
        @participatory_process ||= feature.participatory_process
      end

      def step
        @step ||= participatory_process.steps.find(form.step_id)
      end
    end
  end
end
