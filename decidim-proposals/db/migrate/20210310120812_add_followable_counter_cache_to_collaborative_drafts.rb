# frozen_string_literal: true

class AddFollowableCounterCacheToCollaborativeDrafts < ActiveRecord::Migration[5.2]
  class CollaborativeDraft < ApplicationRecord
    self.table_name = "decidim_proposals_collaborative_drafts"
  end

  def change
    add_column :decidim_proposals_collaborative_drafts, :follows_count, :integer, null: false, default: 0, index: true

    reversible do |dir|
      dir.up do
        CollaborativeDraft.reset_column_information
        CollaborativeDraft.find_each do |record|
          record.class.reset_counters(record.id, :follows)
        end
      end
    end
  end
end
