class CreateDecidimPages < ActiveRecord::Migration[5.0]
  def change
    create_table :decidim_pages do |t|
      t.hstore :title, null: false
      t.string :slug, null: false
      t.hstore :content, null: false
      t.references :decidim_organization, foreign_key: true, index: true
      t.timestamps
    end
  end
end
