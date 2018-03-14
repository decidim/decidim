# frozen_string_literal: true

class RenameMaximumVotesPerProposalToTresholdPerProposal < ActiveRecord::Migration[5.1]
  def up
    execute <<~SQL
      UPDATE decidim_components
      SET settings = replace(settings::TEXT,'"maximum_votes_per_proposal":','"treshold_per_proposal"')::jsonb
      WHERE manifest_name = 'proposals';
    SQL
  end

  def down
    execute <<~SQL
      UPDATE decidim_components
      SET settings = replace(settings::TEXT,'"treshold_per_proposal":','"maximum_votes_per_proposal"')::jsonb
      WHERE manifest_name = 'proposals';
    SQL
  end
end
