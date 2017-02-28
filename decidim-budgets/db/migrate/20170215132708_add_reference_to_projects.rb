class AddReferenceToProjects < ActiveRecord::Migration[5.0]
  def change
    add_column :decidim_budgets_projects, :reference, :string
    Decidim::Budgets::Project.find_each(&:save)
    change_column_null :decidim_budgets_projects, :reference, false
  end
end
