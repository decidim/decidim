# This migration comes from decidim_participatory_processes (originally 20161020080756)
# frozen_string_literal: true

class AddPositionToSteps < ActiveRecord::Migration[5.0]
  def change
    add_column :decidim_participatory_process_steps, :position, :integer, null: false
    add_index :decidim_participatory_process_steps, :position, order: { position: :asc }, name: "index_order_by_position_for_steps"
    add_index :decidim_participatory_process_steps, [:decidim_participatory_process_id, :position], unique: true, name: "index_unique_position_for_process"
  end
end
