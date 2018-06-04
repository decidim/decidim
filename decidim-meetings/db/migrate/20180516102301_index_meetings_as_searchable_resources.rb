# frozen_string_literal: true

class IndexMeetingsAsSearchableResources < ActiveRecord::Migration[5.1]
  def up
    # Decidim::Meetings::Meeting.find_each(&:add_to_index_as_search_resource)
  end

  def down
    # Decidim::SearchableResource.where(resource_type: "Decidim::Meetings::Meeting").destroy_all
  end
end
