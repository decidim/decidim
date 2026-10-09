# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module HasSettings
    extend ActiveSupport::Concern

    included do
      after_initialize :default_values
    end

    class_methods do
      # Returns a Class with the attributes sanitized, coerced  and filtered
      # to the right type. See Decidim::SettingsManifest#schema.
      def build_settings(manifest, settings_name, data, organization)
        manifest.settings(settings_name).schema.new(data, organization.default_locale)
      end
    end

    def settings
      new_settings_schema(:global, self[:settings]["global"])
    end

    def settings=(data)
      self[:settings]["global"] = new_settings_schema(:global, data)
    end

    def current_settings
      if participatory_space.allows_phases?
        active_phase_settings
      else
        default_phase_settings
      end
    end

    def default_phase_settings
      new_settings_schema(:phase, self[:settings]["default_phase"])
    end

    def default_phase_settings=(data)
      self[:settings]["default_phase"] = new_settings_schema(:phase, data)
    end

    def phase_settings
      return {} unless participatory_space.allows_phases?

      participatory_space.phases.to_h do |phase|
        [phase.id.to_s, new_settings_schema(:phase, self[:settings].dig("phases", phase.id.to_s))]
      end
    end

    def phase_settings=(data)
      self[:settings]["phases"] = data.each_with_object({}) do |(key, value), result|
        result[key.to_s] = new_settings_schema(:phase, value)
      end
    end

    private

    def active_phase_settings
      return unless participatory_space.allows_phases?

      active_phase = participatory_space.active_phase
      return default_phase_settings unless active_phase

      phase_settings.fetch(active_phase.id.to_s)
    end

    def new_settings_schema(settings_name, data)
      return {} unless manifest && participatory_space

      self.class.build_settings(manifest, settings_name, data, participatory_space.organization)
    end

    def default_values
      self[:settings] ||= {}
    end
  end
end
