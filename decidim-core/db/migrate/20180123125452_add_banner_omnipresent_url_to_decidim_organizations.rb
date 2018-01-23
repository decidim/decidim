# frozen_string_literal: true

class AddBannerOmnipresentUrlToDecidimOrganizations < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_organizations, :banner_omnipresent_url, :string
  end
end
