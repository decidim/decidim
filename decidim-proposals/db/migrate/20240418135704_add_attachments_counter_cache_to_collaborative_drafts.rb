# frozen_string_literal: true

class AddAttachmentsCounterCacheToCollaborativeDrafts < ActiveRecord::Migration[6.1]
  def change
    add_column :decidim_proposals_collaborative_drafts, :attachments_count, :integer, null: false, default: 0

    reversible do |dir|
      dir.up do
        Decidim::Proposals::CollaborativeDraft.reset_column_information
        Decidim::Proposals::CollaborativeDraft.find_each do |record|
          record.class.reset_counters(record.id, :attachments)
        end
      end
    end
  end
end
