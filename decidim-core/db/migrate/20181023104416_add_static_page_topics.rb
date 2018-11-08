# frozen_string_literal: true

class AddStaticPageTopics < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_static_page_topics do |t|
      t.column :title, :jsonb, null: false
      t.column :description, :jsonb, null: false
      t.references :organization, null: false
    end

    change_table :decidim_static_pages do |t|
      t.references :topic
    end
  end
end
