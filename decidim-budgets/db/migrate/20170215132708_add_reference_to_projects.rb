# frozen_string_literal: true

class AddReferenceToProjects < ActiveRecord::Migration[5.0]
  class Project < ApplicationRecord
    self.table_name = :decidim_budgets_projects
  end

  def change
    add_column :decidim_budgets_projects, :reference, :string
    Project.find_each(&:save)
    change_column_null :decidim_budgets_projects, :reference, false
  end
end
