# frozen_string_literal: true

class AddCostsToProposals < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_proposals_proposals, :cost, :decimal
    add_column :decidim_proposals_proposals, :cost_report, :jsonb
    add_column :decidim_proposals_proposals, :execution_period, :jsonb
  end
end
