# frozen_string_literal: true

class AddSocialMediaHandlersToOrganization < ActiveRecord::Migration[5.0]
  def change
    add_column :decidim_organizations, :instagram_handler, :string
    add_column :decidim_organizations, :facebook_handler, :string
    add_column :decidim_organizations, :youtube_handler, :string
    add_column :decidim_organizations, :github_handler, :string
  end
end
