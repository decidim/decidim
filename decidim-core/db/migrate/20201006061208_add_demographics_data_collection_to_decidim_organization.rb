# frozen_string_literal: true

class AddDemographicsDataCollectionToDecidimOrganization < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_organizations, :demographics_data_collection, :boolean, default: false
  end
end
