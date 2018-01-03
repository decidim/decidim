# This migration comes from decidim (originally 20161110105712)
# frozen_string_literal: true

class CreateDecidimFeatures < ActiveRecord::Migration[5.0]
  def change
    create_table :decidim_features do |t|
      t.string :manifest_name
      t.jsonb :name
      t.references :decidim_participatory_process, index: true
    end
  end
end
