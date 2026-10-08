# frozen_string_literal: true

class RemoveCollaborativeDraftsCommentReplies < ActiveRecord::Migration[7.2]
  class Comment < ApplicationRecord
    self.table_name = "decidim_comments_comments"
  end

  class CommentVote < ApplicationRecord
    self.table_name = "decidim_comments_comment_votes"
  end

  class Moderation < ApplicationRecord
    self.table_name = "decidim_moderations"
  end

  class Report < ApplicationRecord
    self.table_name = "decidim_reports"
  end

  class SearchableResource < ApplicationRecord
    self.table_name = "decidim_searchable_resources"
  end

  COLLABORATIVE_DRAFT_TYPE = "Decidim::Proposals::CollaborativeDraft"
  COMMENT_TYPE = "Decidim::Comments::Comment"

  def up
    comments = Comment.where(decidim_root_commentable_type: COLLABORATIVE_DRAFT_TYPE)
    moderations = Moderation.where(decidim_reportable_type: COMMENT_TYPE, decidim_reportable_id: comments.select(:id))

    CommentVote.where(decidim_comment_id: comments.select(:id)).delete_all
    SearchableResource.where(resource_type: COMMENT_TYPE, resource_id: comments.select(:id)).delete_all
    Report.where(decidim_moderation_id: moderations.select(:id)).delete_all
    moderations.delete_all
    comments.delete_all
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
