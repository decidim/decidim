class AddPositionToSteps < ActiveRecord::Migration[5.0]
  def change
    add_column :decidim_participatory_process_steps, :position, :integer
    add_index :decidim_participatory_process_steps, [:decidim_participatory_process_id, :position], order: { position: :desc }, name: "index_check_position_for_steps"
  end
end
