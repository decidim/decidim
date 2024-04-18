# frozen_string_literal: true

class AddAttachmentsCounterCacheToProjects < ActiveRecord::Migration[6.1]
  def change
    add_column :decidim_budgets_projects, :attachments_count, :integer, null: false, default: 0

    reversible do |dir|
      dir.up do
        Decidim::Budgets::Project.reset_column_information
        Decidim::Budgets::Project.find_each do |record|
          record.class.reset_counters(record.id, :attachments)
        end
      end
    end
  end
end
