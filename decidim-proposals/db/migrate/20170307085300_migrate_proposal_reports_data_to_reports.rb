class MigrateProposalReportsDataToReports < ActiveRecord::Migration[5.0]
  class Decidim::Proposals::ProposalReport < ApplicationRecord
  end

  def change
    Decidim::Proposals::ProposalReport.all.each do |proposal_report|
      Decidim::Report.create!({
        reportable: proposal_report.proposal,
        user: proposal_report.user,
        reason: proposal_report.reason,
        details: proposal_report.details
      })
    end

    drop_table :decidim_proposals_proposal_reports
  end
end
