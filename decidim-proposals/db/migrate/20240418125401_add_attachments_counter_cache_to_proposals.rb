# frozen_string_literal: true

class AddAttachmentsCounterCacheToProposals < ActiveRecord::Migration[6.1]
  def change
    add_column :decidim_proposals_proposals, :attachments_count, :integer, null: false, default: 0

    reversible do |dir|
      dir.up do
        Decidim::Proposals::Proposal.reset_column_information
        Decidim::Proposals::Proposal.find_each do |record|
          record.class.reset_counters(record.id, :attachments)
        end
      end
    end
  end
end
