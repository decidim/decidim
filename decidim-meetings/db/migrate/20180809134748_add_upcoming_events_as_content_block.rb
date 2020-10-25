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
      next if ContentBlock.where(decidim_organization_id: organization.id).exists?(manifest_name: "upcoming_events")

      last_weight = ContentBlock.where(decidim_organization_id: organization.id).order("weight DESC").limit(1).pluck(:weight).last.to_i

      ContentBlock.create!(
        decidim_organization_id: organization.id,
        weight: last_weight,
        scope: :homepage,
        manifest_name: :upcoming_events,
        published_at: Time.current
      )
    end
  end
end
