class AddActiveFlagToStep < ActiveRecord::Migration[5.0]
  def change
    add_column :decidim_participatory_process_steps, :active, :boolean, default: false
  end
end
