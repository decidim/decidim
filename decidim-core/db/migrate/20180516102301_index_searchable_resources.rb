# frozen_string_literal: true

class IndexSearchableResources < ActiveRecord::Migration[5.1]
  def up
    Decidim::Proposals::Proposal.find_each {|p| p.add_to_index_as_search_rsrc }
    Decidim::Meetings::Meeting.find_each {|m| m.add_to_index_as_search_rsrc }
  end

  def down
    Decidim::SearchableResource.destroy_all
  end
end
