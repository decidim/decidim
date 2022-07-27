# frozen_string_literal: true

class AddCoreContentBlocks < ActiveRecord::Migration[5.2]
  class Organization < ApplicationRecord
    self.table_name = :decidim_organizations
  end

  class ContentBlock < ApplicationRecord
    self.table_name = :decidim_content_blocks
  end

  def change
    default_blocks = Decidim.content_blocks.for(:homepage).select(&:default)

    Organization.pluck(:id).each do |organization_id|
      default_blocks.each_with_index do |manifest, index|
        weight = (index + 1) * 10
        ContentBlock.create(
          decidim_organization_id: organization_id,
          weight:,
          scope: :homepage,
          manifest_name: manifest.name,
          published_at: Time.current
        )
      end
    end
  end
end
