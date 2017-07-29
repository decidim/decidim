# frozen_string_literal: true

class MigrateProposalReportsDataToReports < ActiveRecord::Migration[5.0]
  class Decidim::Proposals::ProposalReport < ApplicationRecord
    belongs_to :user, foreign_key: "decidim_user_id", class_name: "Decidim::User"
    belongs_to :proposal, foreign_key: "decidim_proposal_id", class_name: "Decidim::Proposals::Proposal"
  end

  def change
    Decidim::Proposals::ProposalReport.find_each do |proposal_report|
      moderation = Decidim::Moderation.find_or_create_by!(reportable: proposal_report.proposal,
                                                          participatory_process: proposal_report.proposal.feature.participatory_space)
      Decidim::Report.create!(moderation: moderation,
                              user: proposal_report.user,
                              reason: proposal_report.reason,
                              details: proposal_report.details)
      moderation.update_attributes!(report_count: moderation.report_count + 1)
    end

    drop_table :decidim_proposals_proposal_reports
    remove_column :decidim_proposals_proposals, :report_count
    remove_column :decidim_proposals_proposals, :hidden_at
  end
end
