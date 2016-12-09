class CreateComments < ActiveRecord::Migration[5.0]
  def change
    create_table :decidim_comments_comments do |t|
      t.text :body, null: false
      t.references :commentable, null: false, polymorphic: true, index: { name: "decidim_comments_comment_commentable" }
      t.references :author, null: false, index: { name: "decidim_comments_comment_author" }

      t.timestamps
    end
  end
end
