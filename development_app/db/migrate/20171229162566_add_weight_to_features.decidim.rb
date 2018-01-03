# This migration comes from decidim (originally 20170125152026)
# frozen_string_literal: true

class AddWeightToFeatures < ActiveRecord::Migration[5.0]
  def change
    add_column :decidim_features, :weight, :integer, default: 0
  end
end
