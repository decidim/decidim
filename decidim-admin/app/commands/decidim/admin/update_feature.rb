# frozen_string_literal: true

module Decidim
  module Admin
    # This command gets called when a feature is created from the admin panel.
    class UpdateFeature < Rectify::Command
      attr_reader :form, :feature

      # Public: Initializes the command.
      #
      # form    - The form from which the data in this feature comes from.
      # feature - The feature to update.
      def initialize(form, feature)
        @manifest = feature.manifest
        @form = form
        @feature = feature
      end

      # Public: Creates the Feature.
      #
      # Broadcasts :ok if created, :invalid otherwise.
      def call
        return broadcast(:invalid) if form.invalid?

        transaction do
          update_feature
          run_hooks
        end

        broadcast(:ok)
      end

      private

      def update_feature
        @feature.update_attributes!(
          name: form.name,
          settings: form.settings,
          default_step_settings: form.default_step_settings,
          step_settings: form.step_settings,
          weight: form.weight
        )
      end

      def run_hooks
        @manifest.run_hooks(:update, @feature)
      end
    end
  end
end
