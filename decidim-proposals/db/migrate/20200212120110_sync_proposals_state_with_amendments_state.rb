# frozen_string_literal: true

class SyncProposalsStateWithAmendmentsState < ActiveRecord::Migration[5.2]
  def up
    execute <<-SQL.squish
      UPDATE decidim_proposals_proposals AS proposals
      SET state = amendments.state
      FROM decidim_amendments AS amendments
      WHERE
        proposals.state IS NULL AND
        amendments.decidim_emendation_type = 'Decidim::Proposals::Proposal' AND
        amendments.decidim_emendation_id = proposals.id AND
        amendments.state IS NOT NULL
    SQL
  end

  def down
    execute <<-SQL.squish
      UPDATE decidim_proposals_proposals AS proposals
      SET state = NULL
      FROM decidim_amendments AS amendments
      WHERE
        amendments.decidim_emendation_type = 'Decidim::Proposals::Proposal' AND
        amendments.decidim_emendation_id = proposals.id AND
        amendments.state IS NOT NULL
    SQL
  end
end
