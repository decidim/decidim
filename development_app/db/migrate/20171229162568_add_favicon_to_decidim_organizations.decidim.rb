# This migration comes from decidim (originally 20170130132833)
# frozen_string_literal: true

class AddFaviconToDecidimOrganizations < ActiveRecord::Migration[5.0]
  def change
    add_column :decidim_organizations, :favicon, :string
  end
end
