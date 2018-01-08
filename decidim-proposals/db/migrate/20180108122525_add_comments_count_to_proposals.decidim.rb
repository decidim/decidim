# frozen_string_literal: true

class AddCommentsCountToProposals < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_proposals_proposals, :comments_count, :integer, default: 0

    Decidim::Proposals::Proposal.reset_column_information

    Decidim::Proposals::Proposal.all.each do |p|
      p.update(comments_count: p.comments.length)
    end
  end
end
