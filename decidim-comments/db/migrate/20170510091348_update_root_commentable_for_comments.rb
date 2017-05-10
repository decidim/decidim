class UpdateRootCommentableForComments < ActiveRecord::Migration[5.0]
  def root_commentable(comment)
    return comment.commentable if comment.depth.zero?
    root_commentable comment.commentable
  end

  def change
    Decidim::Comments::Comment.where(depth: 0).update_all(
      "decidim_root_commentable_id = #{decidim_commentable_id}, decidim_root_commentable_type = #{decidim_commentable_type}"
    )

    Decidim::Comments::Comment.where("depth > 0").find_each do |comment|
      comment.root_commentable = root_commentable(comment)
      comment.save
    end
  end
end
