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
        @feature = feature.update_attributes(
          name: form.name,
          configuration: configuration
        )
      end

      def configuration
        (@feature.configuration || {}).merge(
          "global" => global_configuration
        )
      end

      def configuration_schema
        @manifest.configuration(:global).schema
      end

      def global_configuration
        configuration_schema.new(form.configuration).attributes
      end

      def run_hooks
        @manifest.run_hooks(:update, @feature)
      end
    end
  end
end
