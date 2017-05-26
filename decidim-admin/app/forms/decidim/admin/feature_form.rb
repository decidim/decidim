# frozen_string_literal: true

module Decidim
  module Admin
    # A form object used to attach a feature to a participatory process from the
    # admin panel.
    #
    class FeatureForm < Decidim::Form
      include TranslatableAttributes

      mimic :feature

      translatable_attribute :name, String
      validates :name, translatable_presence: true

      attribute :settings, Object
      attribute :manifest
      attribute :weight, Integer, default: 0

      attribute :step_settings, Hash[String => Object]
      attribute :participatory_process

      def map_model(model)
        self.attributes = model.attributes
        self.settings = model.settings
      end

      def settings?
        settings.manifest.attributes.any?
      end

      def step_settings?
        return false unless participatory_process.steps.any?

        step_settings
          .values
          .map(&:manifest)
          .flat_map(&:attributes)
          .flat_map(&:keys)
          .any?
      end
    end
  end
end
