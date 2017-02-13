class CreateDecidimNewsletters < ActiveRecord::Migration[5.0]
  def change
    create_table :decidim_newsletters do |t|
      t.jsonb :subject
      t.jsonb :body
      t.references :author, foreign_key: true
      t.datetime :sent_at
      t.string :send_to

      t.timestamps
    end
  end
end
