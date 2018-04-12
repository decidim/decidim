# frozen_string_literal: true

module Decidim
  module Admin
    # This command gets called when a feature is created from the admin panel.
    class UpdateFeature < Rectify::Command
      attr_reader :form, :feature, :previous_settings

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

        broadcast(:ok, settings_changed?, previous_settings, current_settings)
      end

      private

      def update_feature
        @previous_settings = @feature.attributes["settings"].dup

        @feature.name = form.name
        @feature.settings = form.settings
        @feature.default_step_settings = form.default_step_settings
        @feature.step_settings = form.step_settings
        @feature.weight = form.weight

        @settings_changed = @feature.settings_changed?

        @feature.save!
      end

      def run_hooks
        @manifest.run_hooks(:update, @feature)
      end

      def settings_changed?
        @settings_changed
      end

      def current_settings
        @feature.attributes["settings"]
      end
    end
  end
end
