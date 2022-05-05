# frozen_string_literal: true

class MoveAuthorshipsToCoauthorships < ActiveRecord::Migration[5.1]
  class Proposal < ApplicationRecord
    self.table_name = :decidim_proposals_proposals
  end

  class Coauthorship < ApplicationRecord
    self.table_name = :decidim_coauthorships
  end

  def change
    proposals = Proposal.all

    proposals.each do |proposal|
      author_id = proposal.attributes["decidim_author_id"]
      user_group_id = proposal.attributes["decidim_user_group_id"]

      next if author_id.nil?

      Coauthorship.create!(
        coauthorable_id: proposal.id,
        coauthorable_type: "Decidim::Proposals::Proposal",
        decidim_author_id: author_id,
        decidim_user_group_id: user_group_id
      )
    end
  end
end
