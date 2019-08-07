# frozen_string_literal: true

class AddCancelDataToSortition < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_module_sortitions_sortitions, :cancel_reason, :jsonb
    add_column :decidim_module_sortitions_sortitions, :cancelled_on, :datetime
    add_column :decidim_module_sortitions_sortitions, :cancelled_by_user_id, :integer, index: true
  end
end
