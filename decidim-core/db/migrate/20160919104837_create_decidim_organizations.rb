class CreateDecidimOrganizations < ActiveRecord::Migration[5.0]
  def change
    create_table :decidim_organizations do |t|
      t.string :name, null: false
      t.string :host, null: false
      t.string :default_locale, null: false
      t.string :available_locales, array: true, default: []
      t.jsonb :welcome_text, null: false

      t.timestamps
    end

    add_index :decidim_organizations, :name, unique: true
    add_index :decidim_organizations, :host, unique: true
  end
end
