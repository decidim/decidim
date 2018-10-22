# frozen_string_literal: true

class AddOrganizationAsAuthor < ActiveRecord::Migration[5.2]
  class Proposal < ApplicationRecord
    self.table_name = :decidim_proposals_proposals
  end
  def change
    official_proposals = Proposal.find_each.select do |proposal|
      proposal.coauthorships.count.zero?
    end

    official_proposals.each do |proposal|
      proposal.add_coauthor(proposal.organization)
    end
  end
end
