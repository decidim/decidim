# frozen_string_literal: true

class CreateDecidimDemographicsDemographics < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_demographics_demographics do |t|
      t.belongs_to :decidim_organization, index: { name: :decidim_demographics_demographics_on_organization_id }, foreign_key: true, null: false
      t.boolean :collect_data, null: false, default: false

      t.timestamps
    end
  end
end
