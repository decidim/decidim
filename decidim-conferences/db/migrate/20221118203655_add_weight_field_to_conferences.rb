# frozen_string_literal: true

class AddWeightFieldToConferences < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_conferences, :weight, :integer, null: false, default: 0
  end
end
