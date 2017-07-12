# This migration comes from decidim (originally 20170131134349)
# frozen_string_literal: true

class AddActionPermissionsToDecidimFeatures < ActiveRecord::Migration[5.0]
  def change
    add_column :decidim_features, :permissions, :jsonb
  end
end
