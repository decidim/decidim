# frozen_string_literal: true

class CreateDecidimProposals < ActiveRecord::Migration[5.0]
  def change
    create_table :decidim_proposals_proposals do |t|
      t.text :title, null: false
      t.text :body, null: false
      t.references :decidim_feature, index: true, null: false
      t.references :decidim_author, index: true
      t.references :decidim_category, index: true
      t.references :decidim_scope, index: true

      t.timestamps
    end
  end
end
