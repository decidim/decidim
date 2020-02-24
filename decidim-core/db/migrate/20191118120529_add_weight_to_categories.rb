# frozen_string_literal: true

class AddWeightToCategories < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_categories, :weight, :integer, null: false, default: 0
  end
end
