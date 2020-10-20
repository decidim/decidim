# frozen_string_literal: true

class CreateDecidimDemographicsDemographics < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_demographics_demographics do |t|
      t.belongs_to :decidim_user, foreign_key: true
      t.jsonb :data

      t.timestamps
    end
  end
end
