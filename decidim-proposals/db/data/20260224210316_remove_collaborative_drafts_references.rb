# frozen_string_literal: true

class RemoveCollaborativeDraftsReferences < ActiveRecord::Migration[7.2]
  class CollaborativeDraft < ApplicationRecord
    self.table_name = "decidim_proposals_collaborative_drafts"
  end

  class CollaborativeDraftCollaboratorRequest < ApplicationRecord
    self.table_name = "decidim_proposals_collaborative_draft_collaborator_requests"
  end

  class Notification < ApplicationRecord
    self.table_name = "decidim_notifications"
  end

  class Follow < ApplicationRecord
    self.table_name = "decidim_follows"
  end

  class Moderation < ApplicationRecord
    self.table_name = "decidim_moderations"
  end

  class Coauthorship < ApplicationRecord
    self.table_name = "decidim_coauthorships"
  end

  class ActionLog < ApplicationRecord
    self.table_name = "decidim_action_logs"
  end

  class Comment < ApplicationRecord
    self.table_name = "decidim_comments_comments"
  end

  class ResourceLink < ApplicationRecord
    self.table_name = "decidim_resource_links"
  end

  class Categorization < ApplicationRecord
    self.table_name = "decidim_categorizations"
  end

  class Attachment < ApplicationRecord
    self.table_name = "decidim_attachments"
  end

  class Version < ApplicationRecord
    self.table_name = "versions"
  end

  COLLABORATIVE_DRAFT_TYPE = "Decidim::Proposals::CollaborativeDraft"
  COLLABORATIVE_DRAFT_COLLABORATOR_REQUEST_TYPE = "Decidim::Proposals::CollaborativeDraftCollaboratorRequest"

  def up
    delete_notifications
    delete_follows
    delete_reports
    delete_coauthorships
    delete_action_logs
    delete_comments
    delete_resource_links
    delete_categorizations
    delete_attachments
    delete_paper_trail_versions_for_collaborative_drafts
    delete_paper_trail_versions_for_collaborator_requests
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def delete_notifications
    Notification.where(decidim_resource_type: COLLABORATIVE_DRAFT_TYPE).delete_all
  end

  def delete_follows
    Follow.where(decidim_followable_type: COLLABORATIVE_DRAFT_TYPE).delete_all
  end

  def delete_reports
    Moderation.where(decidim_reportable_type: COLLABORATIVE_DRAFT_TYPE).delete_all
  end

  def delete_coauthorships
    Coauthorship.where(coauthorable_type: COLLABORATIVE_DRAFT_TYPE).delete_all
  end

  def delete_action_logs
    ActionLog.where(resource_type: COLLABORATIVE_DRAFT_TYPE).delete_all
  end

  def delete_comments
    Comment.where(decidim_commentable_type: COLLABORATIVE_DRAFT_TYPE).delete_all
  end

  def delete_resource_links
    ResourceLink.where(from_type: COLLABORATIVE_DRAFT_TYPE).delete_all
    ResourceLink.where(to_type: COLLABORATIVE_DRAFT_TYPE).delete_all
  end

  def delete_categorizations
    Categorization.where(categorizable_type: COLLABORATIVE_DRAFT_TYPE).delete_all
  end

  def delete_attachments
    Attachment.where(attached_to_type: COLLABORATIVE_DRAFT_TYPE).delete_all
  end

  def delete_paper_trail_versions_for_collaborative_drafts
    Version.where(item_type: COLLABORATIVE_DRAFT_TYPE).delete_all
  end

  def delete_paper_trail_versions_for_collaborator_requests
    Version.where(item_type: COLLABORATIVE_DRAFT_COLLABORATOR_REQUEST_TYPE).delete_all
  end
end
