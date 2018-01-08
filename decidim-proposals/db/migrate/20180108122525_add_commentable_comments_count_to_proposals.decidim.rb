# frozen_string_literal: true

class AddCommentableCommentsCountToProposals < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_proposals_proposals, :commentable_comments_count, :integer, default: 0

    Decidim::Proposals::Proposal.reset_column_information

    Decidim::Proposals::Proposal.all.each do |p|
      p.update(commentable_comments_count: p.comments.length)
    end
  end
end
