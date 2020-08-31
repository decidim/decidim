# frozen_string_literal: true

class IndexForeignKeysInDecidimConferences < ActiveRecord::Migration[5.2]
  def change
    add_index :decidim_conferences, :decidim_scope_id
  end
end
