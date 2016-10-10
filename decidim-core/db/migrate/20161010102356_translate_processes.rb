class TranslateProcesses < ActiveRecord::Migration[5.0]
  def change
    remove_column :decidim_participatory_processes, :title
    remove_column :decidim_participatory_processes, :subtitle
    remove_column :decidim_participatory_processes, :description
    remove_column :decidim_participatory_processes, :short_description

    change_table :decidim_participatory_processes do |t|
      t.hstore :title, null: false
      t.hstore :subtitle, null: false
      t.hstore :short_description, null: false
      t.hstore :description, null: false
    end
  end
end
