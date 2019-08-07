# frozen_string_literal: true

class CreateProposalEndorsements < ActiveRecord::Migration[5.1]
  def change
    create_table :decidim_proposals_proposal_endorsements do |t|
      t.references :decidim_proposal, null: false, index: { name: "decidim_proposals_proposal_endorsement_proposal" }
      t.references :decidim_author, null: false, index: { name: "decidim_proposals_proposal_endorsement_author" }
      t.references :decidim_user_group, null: true, index: { name: "decidim_proposals_proposal_endorsement_user_group" }

      t.timestamps
    end

    add_index :decidim_proposals_proposal_endorsements, "decidim_proposal_id, decidim_author_id, (coalesce(decidim_user_group_id,-1))", unique: true, name:
      "decidim_proposals_proposal_endorsmt_proposal_auth_ugroup_uniq"
  end
end
