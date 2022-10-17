# frozen_string_literal: true

class MoveTermsAndConditionsContentToContentBlock < ActiveRecord::Migration[6.1]
  class Organization < ApplicationRecord
    self.table_name = :decidim_organizations
  end

  class StaticPage < ApplicationRecord
    self.table_name = :decidim_static_pages
  end

  class ContentBlock < ApplicationRecord
    self.table_name = :decidim_content_blocks
  end

  def up
    Organization.find_each do |organization|
      page = static_page(organization.id)
      next unless page

      content_block = content_block(organization.id, page.id)
      next if content_block

      content_block = ContentBlock.create(content_block_params(organization.id, page.id))
      content_block.published_at = Time.current
      content_block.weight = 1
      content_block.settings = { summary: page.content }
      content_block.save

      page.content = {}
      page.save
    end
  end

  def down
    Organization.find_each do |organization|
      page = static_page(organization.id)
      next unless page

      content_block = content_block(organization.id, page.id)
      next unless content_block

      page.content = content_block.settings["summary"]
      page.save

      content_block.delete
    end
  end

  def static_page(organization_id)
    StaticPage.find_by(decidim_organization_id: organization_id, slug: "terms-and-conditions")
  end

  def content_block(organization_id, page_id)
    ContentBlock.find_by(content_block_params(organization_id, page_id))
  end

  def content_block_params(organization_id, page_id)
    {
      decidim_organization_id: organization_id,
      scope_name: :static_page,
      manifest_name: :summary,
      scoped_resource_id: page_id
    }
  end
end
