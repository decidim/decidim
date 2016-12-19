class CreateCommentVotes < ActiveRecord::Migration[5.0]
  def change
    create_table :decidim_comments_comment_votes do |t|
      t.integer :weight, null: false
      t.references :decidim_comment, null: false, index: { name: "decidim_comments_comment_vote_comment" }
      t.references :decidim_author, null: false, index: { name: "decidim_comments_comment_vote_author" }
      
      t.timestamps
    end
  end
end
