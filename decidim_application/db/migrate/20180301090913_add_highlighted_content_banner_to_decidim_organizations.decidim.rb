# This migration comes from decidim (originally 20180125063433)
# frozen_string_literal: true

class AddHighlightedContentBannerToDecidimOrganizations < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_organizations, :highlighted_content_banner_enabled, :boolean, null: false, default: false
    add_column :decidim_organizations, :highlighted_content_banner_title, :jsonb
    add_column :decidim_organizations, :highlighted_content_banner_short_description, :jsonb
    add_column :decidim_organizations, :highlighted_content_banner_action_title, :jsonb
    add_column :decidim_organizations, :highlighted_content_banner_action_subtitle, :jsonb
    add_column :decidim_organizations, :highlighted_content_banner_action_url, :string
    add_column :decidim_organizations, :highlighted_content_banner_image, :string
  end
end
