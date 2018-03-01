# This migration comes from decidim (originally 20180123125409)
# frozen_string_literal: true

class AddOmnipresentBannerTitleToDecidimOrganizations < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_organizations, :omnipresent_banner_title, :jsonb
  end
end
