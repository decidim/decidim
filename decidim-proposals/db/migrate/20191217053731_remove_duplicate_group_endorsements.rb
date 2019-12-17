# frozen_string_literal: true

class RemoveDuplicateGroupEndorsements < ActiveRecord::Migration[5.2]
  def change
    valid_group_endorsements = Decidim::Proposals::ProposalEndorsement.select(
      "MIN(id) as id, decidim_user_group_id"
    ).group(:decidim_user_group_id).where.not(decidim_user_group_id: nil)

    duplicates = Decidim::Proposals::ProposalEndorsement.where(
      "id NOT IN (?) AND decidim_user_group_id IS NOT NULL", valid_group_endorsements.map(&:id)
    )

    duplicates.destroy_all
  end
end
