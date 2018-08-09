# frozen_string_literal: true

class AddUpcomingEventsAsContentBlock < ActiveRecord::Migration[5.2]
  class Organization < ApplicationRecord
    self.table_name = :decidim_organizations
  end

  class ContentBlock < ApplicationRecord
    self.table_name = :decidim_content_blocks
  end

  def change
    Organization.find_each do |organization|
      next if organization.content_blocks.where(manifest_name: "upcoming_events").exists?

      ContentBlock.create(
        decidim_organization_id: organization.id,
        weight: organization.content_blocks.last.try(:weight).to_i + 10,
        scope: :homepage,
        manifest_name: :upcoming_events,
        published_at: Time.current
      )
    end
  end
end
