# frozen_string_literal: true

class IndexProposalsAsSearchableResources < ActiveRecord::Migration[5.1]
  def up
    Decidim::Proposals::Proposal.find_each(&:add_to_index_as_search_rsrc)
  end

  def down
    Decidim::SearchableResource.where(resource_type: "Decidim::Proposals::Proposal").destroy_all
  end
end
