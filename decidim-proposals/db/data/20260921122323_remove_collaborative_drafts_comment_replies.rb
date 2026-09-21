# frozen_string_literal: true

class RemoveCollaborativeDraftsCommentReplies < ActiveRecord::Migration[7.2]
  class Comment < ApplicationRecord
    self.table_name = "decidim_comments_comments"
  end

  COLLABORATIVE_DRAFT_TYPE = "Decidim::Proposals::CollaborativeDraft"

  def up
    Comment.where(decidim_root_commentable_type: COLLABORATIVE_DRAFT_TYPE).delete_all
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
