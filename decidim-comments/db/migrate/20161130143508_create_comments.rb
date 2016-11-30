class CreateComments < ActiveRecord::Migration[5.0]
  def change
    create_table :decidim_comments_comments do |t|
      t.text :body
      t.references :commentable, polymorphic: true, index: { name: "decidim_comments_comment_commentable"}
      t.references :author

      t.timestamps
    end
  end
end
