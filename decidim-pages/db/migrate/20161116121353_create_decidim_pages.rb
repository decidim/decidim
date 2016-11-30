class CreateDecidimPages < ActiveRecord::Migration[5.0]
  def change
    create_table :decidim_pages_pages do |t|
      t.jsonb :title
      t.jsonb :body
      t.references :decidim_feature

      t.timestamps
    end
  end
end
