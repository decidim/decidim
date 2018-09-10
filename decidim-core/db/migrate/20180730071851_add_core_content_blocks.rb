# frozen_string_literal: true

class AddCoreContentBlocks < ActiveRecord::Migration[5.2]
  class Organization < ApplicationRecord
    self.table_name = :decidim_organizations
  end

  class ContentBlock < ApplicationRecord
    self.table_name = :decidim_content_blocks
  end

  def change
    default_blocks = [:hero, :sub_hero, :highlighted_content_banner, :how_to_participate, :stats, :footer_sub_hero]

    Organization.pluck(:id).each do |organization_id|
      default_blocks.each_with_index do |manifest_name, index|
        weight = (index + 1) * 10
        ContentBlock.create(
          decidim_organization_id: organization_id,
          weight: weight,
          scope: :homepage,
          manifest_name: manifest_name,
          published_at: Time.current
        )
      end
    end
  end
end
