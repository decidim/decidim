# frozen_string_literal: true

class AddFollowableCounterCacheToBudgets < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_budgets_projects, :follows_count, :integer, null: false, default: 0, index: true

    reversible do |dir|
      dir.up do
        Decidim::Budgets::Project.reset_column_information
        Decidim::Budgets::Project.find_each do |record|
          record.class.reset_counters(record.id, :follows)
        end
      end
    end
  end
end
