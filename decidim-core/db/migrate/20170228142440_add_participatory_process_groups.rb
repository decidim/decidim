class AddParticipatoryProcessGroups < ActiveRecord::Migration[5.0]
  def change
    create_table :decidim_participatory_process_groups do |t|
      t.jsonb :name, null: false
      t.jsonb :description, null: false
      t.string :hero_image

      t.references :decidim_organization, index: { name: "decidim_participatory_process_group_organization" }

      t.timestamps
    end

    add_column :decidim_participatory_processes, :decidim_participatory_process_group_id, :integer
  end
end
