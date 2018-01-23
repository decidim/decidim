# frozen_string_literal: true

class AddEnableBannerOmnipresentToDecidimOrganizations < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_organizations, :enable_banner_omnipresent, :boolean, null: false, default: false
  end
end
