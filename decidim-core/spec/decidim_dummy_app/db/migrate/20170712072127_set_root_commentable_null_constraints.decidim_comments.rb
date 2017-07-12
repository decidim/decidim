# This migration comes from decidim_comments (originally 20170510091409)
# frozen_string_literal: true

class SetRootCommentableNullConstraints < ActiveRecord::Migration[5.0]
  def change
    change_column_null(:decidim_comments_comments, :decidim_root_commentable_id, false)
    change_column_null(:decidim_comments_comments, :decidim_root_commentable_type, false)
  end
end
