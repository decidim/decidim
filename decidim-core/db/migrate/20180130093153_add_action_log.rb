# frozen_string_literal: true

class AddActionLog < ActiveRecord::Migration[5.1]
  def change
    create_table :decidim_action_logs do |t|
      t.references :decidim_organization, null: false, index: { name: "index_action_logs_on_organization_id" }
      t.references :decidim_user, null: false, index: { name: "index_action_logs_on_user_id" }
      t.references :decidim_feature, index: { name: "index_action_logs_on_feature_id" }
      t.references :resource, polymorphic: true, null: false, index: { name: "index_action_logs_on_resource_type_and_id" }
      t.references :participatory_space, polymorphic: true, index: { name: "index_action_logs_on_space_type_and_id" }
      t.string :action, null: false
      t.jsonb :extra

      t.timestamps
    end
    add_index :decidim_action_logs, :created_at
  end
end
