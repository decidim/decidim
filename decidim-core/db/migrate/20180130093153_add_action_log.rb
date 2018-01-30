# frozen_string_literal: true

class AddActionLog < ActiveRecord::Migration[5.1]
  def change
    create_table :decidim_action_logs do |t|
      t.integer :decidim_organization_id, null: false
      t.integer :decidim_user_id, null: false
      t.integer :decidim_feature_id
      t.references :resource, polymorphic: true, null: false
      t.references :participatory_space, polymorphic: true, index: { name: "index_action_logs_on_space_type_and_id" }
      t.string :action, null: false
      t.jsonb :extra

      t.timestamps
    end
  end
end
