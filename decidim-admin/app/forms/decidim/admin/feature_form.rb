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

      attribute :configuration, Object
      attribute :manifest

      attribute :step_configurations, Hash[String => Object]

      def map_model(model)
        self.attributes = model.attributes
        self.configuration = model.configuration
      end

      def configuration?
        configuration.manifest.attributes.any?
      end

      def step_configurations?
        return false unless participatory_process.steps.any?

        step_configurations
          .values
          .map(&:manifest)
          .flat_map(&:attributes)
          .flat_map(&:keys)
          .any?
      end
    end
  end
end
