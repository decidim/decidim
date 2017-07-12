# This migration comes from decidim (originally 20170110133113)
# frozen_string_literal: true

class AddConfigurationToFeatures < ActiveRecord::Migration[5.0]
  def change
    change_table :decidim_features do |t|
      t.jsonb :settings, default: {}
    end
  end
end
