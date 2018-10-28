# frozen_string_literal: true

class CreateDecidimResourcePermissions < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_resource_permissions do |t|
      t.belongs_to :resource, polymorphic: true, index: { name: "index_decidim_resource_permissions_on_r_type_and_r_id", unique: true }
      t.jsonb :permissions, default: {}

      t.timestamps
    end
  end
end
