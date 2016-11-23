# frozen_string_literal: true
module Decidim
  module Admin
    # This command gets called when a feature is created from the admin panel.
    class CreateFeature < Rectify::Command
      def initialize(form, participatory_process)
        @form = form
        @participatory_process = participatory_process
      end

      # Public: Creates the Feature.
      #
      # Broadcasts :ok if created, :invalid otherwise.
      def call
        return broadcast(:invalid) if form.invalid?

        create_feature
        broadcast(:ok)
      end

      private

      attr_reader :form

      def create_feature
        @feature = Feature.create!(
          feature_type: feature_manifest.name,
          name: form.name,
          participatory_process: @participatory_process
        )
      end

      def feature_manifest
        @feature_manifest ||= Decidim.features.find do |manifest|
          manifest.name == form.feature_type.to_sym
        end
      end
    end
  end
end
