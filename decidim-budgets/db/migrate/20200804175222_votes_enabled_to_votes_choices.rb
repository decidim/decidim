# frozen_string_literal: true

class VotesEnabledToVotesChoices < ActiveRecord::Migration[5.2]
  class Component < ApplicationRecord
    self.table_name = :decidim_components
  end

  def up
    budget_components.each do |component|
      steps = component["settings"] && component["settings"]["steps"]
      default_step = component["settings"] && component["settings"]["default_step"]

      if steps.present?
        new_steps_settings = component["settings"]["steps"].each_with_object({}) do |(step, config), new_config|
          votes_value = config["votes_enabled"] ? "enabled" : "disabled"

          new_config[step] = config.merge(votes: votes_value).except("votes_enabled")
          new_config
        end
        component["settings"]["steps"] = new_steps_settings
        component.save!
      elsif default_step.present?
        votes_value = component["settings"]["default_step"]["votes_enabled"] ? "enabled" : "disabled"

        new_default_step_settings = component["settings"]["default_step"].merge(votes: votes_value).except("votes_enabled")
        component["settings"]["default_step"] = new_default_step_settings
        component.save!
      end
    end
  end

  def budget_components
    @budget_components ||= Component.where(manifest_name: "budgets")
  end
end
