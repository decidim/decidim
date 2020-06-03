class CreateDecidimTranslatedFields < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_translated_fields do |t|
      t.string :field_name
      t.string :translation_locale
      t.string :translation_value
      t.string :external_reference
      t.timestamp :translation_at

      t.timestamps
    end
  end
end
