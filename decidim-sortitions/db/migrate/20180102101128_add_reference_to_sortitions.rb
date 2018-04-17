# frozen_string_literal: true

class AddReferenceToSortitions < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_module_sortitions_sortitions, :reference, :string
    change_column_null :decidim_module_sortitions_sortitions, :reference, false
  end
end
