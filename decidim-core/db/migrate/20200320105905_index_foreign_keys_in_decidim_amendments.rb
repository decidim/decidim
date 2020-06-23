# frozen_string_literal: true

class IndexForeignKeysInDecidimAmendments < ActiveRecord::Migration[5.2]
  def change
    add_index :decidim_amendments, :decidim_emendation_id
  end
end
