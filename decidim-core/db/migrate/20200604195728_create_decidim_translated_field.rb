# frozen_string_literal: true

class CreateDecidimTranslatedField < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_translated_fields do |t|
      t.belongs_to :fields, polymorphic: true
      t.string :field_name, null: false
      t.string :translation_locale, null: false
      t.string :translation_value
      t.timestamp :translated_at
    end

    add_index :decidim_translated_fields, [:field_name, :translation_locale], unique: true,
                                                                              name: "index_unique_field_and_locale"
  end
end
