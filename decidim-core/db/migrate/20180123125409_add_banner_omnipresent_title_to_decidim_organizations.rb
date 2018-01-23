# frozen_string_literal: true

class AddBannerOmnipresentTitleToDecidimOrganizations < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_organizations, :banner_omnipresent_title, :jsonb
  end
end
