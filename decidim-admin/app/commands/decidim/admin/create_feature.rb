# frozen_string_literal: true
module Decidim
  module Admin
    # This command gets called when a feature is created from the admin panel.
    class CreateFeature < Rectify::Command
      attr_reader :form, :manifest, :participatory_process

      # Public: Initializes the command.
      #
      # manifest              - The feature's manifest to create a feature from.
      # form                  - The form from which the data in this feature comes from.
      # participatory_process - The participatory process that will hold this feature.
      def initialize(manifest, form, participatory_process)
        @manifest = manifest
        @form = form
        @participatory_process = participatory_process
      end

      # Public: Creates the Feature.
      #
      # Broadcasts :ok if created, :invalid otherwise.
      def call
        return broadcast(:invalid) if form.invalid?

        transaction do
          create_feature
          run_hooks
        end

        broadcast(:ok)
      end

      private

      def create_feature
        @feature = Feature.create!(
          manifest_name: manifest.name,
          name: form.name,
          participatory_process: participatory_process,
          settings: @form.settings,
          step_settings: form.step_settings
        )
      end

      def run_hooks
        manifest.run_hooks(:create, @feature)
      end
    end
  end
end
