# frozen_string_literal: true

class AddOmnipresentBannerUrlToDecidimOrganizations < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_organizations, :omnipresent_banner_url, :string
  end
end
