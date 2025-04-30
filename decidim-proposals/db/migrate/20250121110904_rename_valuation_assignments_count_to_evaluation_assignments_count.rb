# frozen_string_literal: true

class RenameValuationAssignmentsCountToEvaluationAssignmentsCount < ActiveRecord::Migration[7.0]
  def change
    rename_column :decidim_proposals_proposals, :valuation_assignments_count, :evaluation_assignments_count

    reversible do |dir|
      dir.up do
        Decidim::Proposals::Proposal.reset_column_information
        Decidim::Proposals::Proposal.unscoped.find_each do |record|
          Decidim::Proposals::Proposal.reset_counters(record.id, :evaluation_assignments)
        end
      end
    end
  end
end
