# frozen_string_literal: true

class CreateDecidimElectionsVotings < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_votings_votings do |t|
      t.string :slug, null: false, index: true
      t.jsonb :title, null: false
      t.jsonb :description, null: false
      t.datetime :start_time
      t.datetime :end_time
      t.string :banner_image
      t.string :introductory_image

      t.timestamps

      t.references :decidim_scope, index: true
      t.references :decidim_organization, foreign_key: true, index: true
    end
  end
end
