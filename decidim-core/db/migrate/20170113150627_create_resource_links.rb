# frozen_string_literal: true

class CreateResourceLinks < ActiveRecord::Migration[5.0]
  def change
    create_table :decidim_resource_links do |t|
      t.references :from, null: false, polymorphic: true, index: true
      t.references :to, null: false, polymorphic: true, index: true
      t.string :name, null: false, index: true
      t.jsonb :data
    end
  end
end
