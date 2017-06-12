class MigrateProjectsCategory < ActiveRecord::Migration[5.1]
  def change
    Decidim::Budgets::Project.find_each do |project|
      Decidim::Categorization.create!(
        decidim_category_id: project.category.id,
        categorizable: project
      )
    end
    remove_column :decidim_budgets_projects, :decidim_category_id
  end
end
