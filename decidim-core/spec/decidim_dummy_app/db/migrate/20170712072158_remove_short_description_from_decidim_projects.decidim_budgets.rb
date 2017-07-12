# This migration comes from decidim_budgets (originally 20170207101750)
# frozen_string_literal: true

class RemoveShortDescriptionFromDecidimProjects < ActiveRecord::Migration[5.0]
  def change
    remove_column :decidim_budgets_projects, :short_description
  end
end
