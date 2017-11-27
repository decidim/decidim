# This migration comes from decidim_proposals (originally 20170215131720)
# frozen_string_literal: true

class AddReportCountToProposals < ActiveRecord::Migration[5.0]
  def change
    add_column :decidim_proposals_proposals, :report_count, :integer, default: 0
  end
end
