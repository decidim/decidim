# This migration comes from decidim (originally 20170308091316)
# frozen_string_literal: true

class CreateModerations < ActiveRecord::Migration[5.0]
  def change
    create_table :decidim_moderations do |t|
      t.references :decidim_participatory_process, null: false, index: { name: "decidim_moderations_participatory_process" }
      t.references :decidim_reportable, null: false, polymorphic: true, index: { unique: true, name: "decidim_moderations_reportable" }
      t.integer :report_count, null: false, default: 0, index: { name: "decidim_moderations_report_count" }
      t.datetime :hidden_at, index: { name: "decidim_moderations_hidden_at" }

      t.timestamps
    end
  end
end
