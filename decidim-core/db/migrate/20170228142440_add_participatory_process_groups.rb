class AddParticipatoryProcessGroups < ActiveRecord::Migration[5.0]
  def change
    create_table :participatory_process_groups do |t|
      t.string :name, null: false
      t.string :description, null: false
      t.string :hero_image
    end
  end
end
