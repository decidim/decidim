# frozen_string_literal: true

class AddColumnsToStaticPageTopic < ActiveRecord::Migration[5.2]
  def change
    change_table :decidim_static_page_topics do |t|
      t.column :weight, :integer, default: nil, null: true
      t.column :show_in_footer, :boolean, default: false, null: false
    end
  end
end
