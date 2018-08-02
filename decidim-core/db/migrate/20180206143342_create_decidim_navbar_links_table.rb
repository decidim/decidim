# frozen_string_literal: true

class CreateDecidimNavbarLinksTable < ActiveRecord::Migration[5.1]
  def change
    create_table :decidim_navbar_links do |t|
      t.references :decidim_organization
      t.jsonb :title
      t.string :link
    end
  end
end
