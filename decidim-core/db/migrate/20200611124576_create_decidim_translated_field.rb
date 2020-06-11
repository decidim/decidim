# frozen_string_literal: true

class CreateDecidimTranslatedField < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_translated_fields do |t|
      t.belongs_to :translted_resource, polymorphic: true, optional: true, index: false
      t.string :field_name, null: false
      t.string :translation_locale, null: false
      t.string :translation_value
      t.timestamp :translated_at
    end

    add_index :decidim_translated_fields, [:translted_resource_id, :translted_resource_type, :field_name, :translation_locale], name: "index_unique_field_translted_resource_locale", unique: true
  end
end
