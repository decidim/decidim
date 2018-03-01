# This migration comes from decidim_accountability (originally 20170425154712)
# frozen_string_literal: true

class CreateAccountabilityStatuses < ActiveRecord::Migration[5.0]
  def change
    create_table :decidim_accountability_statuses do |t|
      t.string :key
      t.jsonb :name
      t.references :decidim_feature, index: true

      t.timestamps
    end
  end
end
