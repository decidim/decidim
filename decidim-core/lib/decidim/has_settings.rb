# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module HasSettings
    extend ActiveSupport::Concern

    included do
      after_initialize :default_values
    end

    def settings
      settings_schema(:global).new(self[:settings]["global"])
    end

    def settings=(data)
      self[:settings]["global"] = settings_schema(:global).new(data)
    end

    def current_settings
      if participatory_space.allows_steps?
        active_step_settings
      else
        default_step_settings
      end
    end

    def default_step_settings
      settings_schema(:step).new(self[:settings]["default_step"])
    end

    def default_step_settings=(data)
      self[:settings]["default_step"] = settings_schema(:step).new(data)
    end

    def step_settings
      return {} unless participatory_space.allows_steps?

      participatory_space.steps.each_with_object({}) do |step, result|
        result[step.id.to_s] = settings_schema(:step).new(self[:settings].dig("steps", step.id.to_s))
      end
    end

    def step_settings=(data)
      self[:settings]["steps"] = data.each_with_object({}) do |(key, value), result|
        result[key.to_s] = settings_schema(:step).new(value)
      end
    end

    private

    def active_step_settings
      return unless participatory_space.allows_steps?

      active_step = participatory_space.active_step
      return default_step_settings unless active_step

      step_settings.fetch(active_step.id.to_s)
    end

    def settings_schema(name)
      manifest.settings(name.to_sym).schema
    end

    def default_values
      self[:settings] ||= {}
    end
  end
end
