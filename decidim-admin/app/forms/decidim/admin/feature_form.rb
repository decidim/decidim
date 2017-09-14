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
      attribute :default_step_settings, Object
      attribute :manifest
      attribute :weight, Integer, default: 0

      attribute :step_settings, Hash[String => Object]
      attribute :participatory_space

      def settings?
        settings.manifest.attributes.any?
      end

      def default_step_settings?
        default_step_settings.manifest.attributes.any?
      end
    end
  end
end
