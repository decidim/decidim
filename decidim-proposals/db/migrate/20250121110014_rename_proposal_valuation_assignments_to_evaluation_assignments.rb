# frozen_string_literal: true

class RenameProposalValuationAssignmentsToEvaluationAssignments < ActiveRecord::Migration[7.0]
  def change
    rename_table :decidim_proposals_valuation_assignments, :decidim_proposals_evaluation_assignments

    rename_index :decidim_proposals_evaluation_assignments,
                 "decidim_proposals_valuation_assignment_proposal",
                 "decidim_proposals_evaluation_assignment_proposal"

    rename_index :decidim_proposals_evaluation_assignments,
                 "decidim_proposals_valuation_assignment_valuator_role",
                 "decidim_proposals_evaluation_assignment_valuator_role"
  end
end
