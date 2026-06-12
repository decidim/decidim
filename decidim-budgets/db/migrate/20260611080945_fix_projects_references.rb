# frozen_string_literal: true

class FixProjectsReferences < ActiveRecord::Migration[7.0]
  class Project < ApplicationRecord
    self.table_name = :decidim_budgets_projects

    belongs_to :budget, foreign_key: "decidim_budgets_budget_id", class_name: "Decidim::Budgets::Budget"
    has_one :component, through: :budget

    include Decidim::HasReference
  end

  def up
    Project.reset_column_information
    Project.find_each do |project|
      next if project.component.blank?

      project[:reference] = nil
      project.send(:store_reference)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
