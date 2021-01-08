# frozen_string_literal: true

class AddDecidimOrganizationToDecidimDemographicsDemographics < ActiveRecord::Migration[5.2]
  def change
    add_reference :decidim_demographics_demographics, :decidim_organization, index: { name: "decidim_demographics_organization" }, foreign_key: true
  end
end
