# frozen_string_literal: true
module Decidim
  module Admin
    # This command gets called when a component is created from the admin panel.
    class CreateComponent < Rectify::Command
      # Public: Initializes a component creation command.
      #
      # form                   - The form from which to get the data from.
      # participatory_processs - The participatory process in which to add the
      #                          newly created component.
      def initialize(form, participatory_process)
        @form = form
        @participatory_process = participatory_process
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

      def feature
        @feature ||= @participatory_process.features.find(form.feature_id)
      end

      private

      attr_reader :form

      def create_component
        @component = Component.create!(
          component_type: component_manifest.name,
          name: form.name,
          feature: feature,
          participatory_process: @participatory_process
        )
      end

      def component_manifest
        @component_manifest ||= Decidim.components.find do |manifest|
          manifest.name == form.component_type.to_sym
        end
      end

      def run_hooks
        component_manifest.run_hooks(:create, @component)
      end
    end
  end
end
