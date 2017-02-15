class AddReferenceToProjects < ActiveRecord::Migration[5.0]
  def change
    add_column :decidim_budgets_projects, :reference, :string
  end
end
