# frozen_string_literal: true

class MigrateProposalsCategory < ActiveRecord::Migration[5.1]
  def change
    Decidim::Proposals::Proposal.find_each do |proposal|
      Decidim::Categorization.create!(
        decidim_category_id: proposal.category.id,
        categorizable: proposal
      )
    end
    remove_column :decidim_proposals_proposals, :decidim_category_id
  end
end
