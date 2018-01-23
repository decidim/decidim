# frozen_string_literal: true

class AddBannerOmnipresentShortDescriptionToDecidimOrganizations < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_organizations, :banner_omnipresent_short_description, :jsonb
  end
end
