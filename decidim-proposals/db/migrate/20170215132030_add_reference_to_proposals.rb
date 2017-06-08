# frozen_string_literal: true

class AddReferenceToProposals < ActiveRecord::Migration[5.0]
  def change
    add_column :decidim_proposals_proposals, :reference, :string
    Decidim::Proposals::Proposal.find_each(&:save)
    change_column_null :decidim_proposals_proposals, :reference, false
  end
end
