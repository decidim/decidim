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
      return {} unless manifest && participatory_space

      data = self[:settings]["global"]&.to_h
      cache_key = [object_id, self[:settings].object_id, manifest.settings(:global).schema, organization.default_locale.dup]

      if @settings_cache_key != cache_key || @settings_cache_data != data
        @settings_cache = new_settings_schema(:global, self[:settings]["global"])
        @settings_cache_key = cache_key
        @settings_cache_data = data.deep_dup
        @settings_cache_collections = collection_setting_names
      end

      # Keep each caller's mutable values, assignments and validation errors separate.
      @settings_cache.dup.tap do |settings|
        @settings_cache_collections.each { |name| settings[name] = settings[name].deep_dup }
      end
    end

    def settings=(data)
      self[:settings]["global"] = new_settings_schema(:global, data)
    end

    def current_settings
      if participatory_space.allows_steps?
        active_step_settings
      else
        default_step_settings
      end
    end

    def default_step_settings
      new_settings_schema(:step, self[:settings]["default_step"])
    end

    def default_step_settings=(data)
      self[:settings]["default_step"] = new_settings_schema(:step, data)
    end

    def step_settings
      return {} unless participatory_space.allows_steps?

      participatory_space.steps.to_h do |step|
        [step.id.to_s, new_settings_schema(:step, self[:settings].dig("steps", step.id.to_s))]
      end
    end

    def step_settings=(data)
      self[:settings]["steps"] = data.each_with_object({}) do |(key, value), result|
        result[key.to_s] = new_settings_schema(:step, value)
      end
    end

    private

    def collection_setting_names
      manifest.settings(:global).attributes.filter_map do |name, attribute|
        name if attribute.translated? || [:array, :integer_with_units, :taxonomy_filters].include?(attribute.type)
      end
    end

    def active_step_settings
      return unless participatory_space.allows_steps?

      active_step = participatory_space.active_step
      return default_step_settings unless active_step

      step_settings.fetch(active_step.id.to_s)
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
