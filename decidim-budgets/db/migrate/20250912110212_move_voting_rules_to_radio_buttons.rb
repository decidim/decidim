# frozen_string_literal: true

class MoveVotingRulesToRadioButtons < ActiveRecord::Migration[7.2]
  class Component < ApplicationRecord
    self.table_name = :decidim_components
  end

  def change
    budgets_components = Component.where(manifest_name: "budgets")

    budgets_components.each do |component|
      settings = component["settings"]["global"]

      settings["voting_rule"] = "threshold_percent" if settings["vote_rule_threshold_percent_enabled"]
      settings["voting_rule"] = "minimum_projects" if settings["vote_rule_minimum_budget_projects_enabled"]
      settings["voting_rule"] = "selected_projects" if settings["vote_rule_selected_projects_enabled"]

      component["settings"]["global"] = settings
      component.save
    end
  end
end
