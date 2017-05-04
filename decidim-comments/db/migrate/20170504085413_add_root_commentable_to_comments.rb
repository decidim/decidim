module Decidim
  module Comments
    class Comment < ApplicationRecord
      # Public: Returns the commentable object of the parent comment
      def root_commentable
        return commentable if depth.zero?
        commentable.root_commentable
      end
    end
  end
end

class AddRootCommentableToComments < ActiveRecord::Migration[5.0]
  def change
    # 1. Add root_commentable fields
    change_table :decidim_comments_comments do |t|
      t.references :decidim_root_commentable, polymorphic: true, index: { name: "decidim_comments_comment_root_commentable" }
    end

    # 2. Store root_commentable data
    Decidim::Comments::Comment.find_each do |comment|
      root_commentable = comment.depth.zero? ? comment.commentable : comment.root_commentable
      comment.root_commentable = root_commentable
      comment.save
    end

    # 3. Set root_commentable fields null constraint
    change_column :decidim_comments_comments, :decidim_root_commentable_id, :integer, null: false
    change_column :decidim_comments_comments, :decidim_root_commentable_type, :string, null: false
  end
end
