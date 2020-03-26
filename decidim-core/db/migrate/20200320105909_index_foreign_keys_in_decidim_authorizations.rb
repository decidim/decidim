# frozen_string_literal: true

class IndexForeignKeysInDecidimAuthorizations < ActiveRecord::Migration[5.2]
  def change
    add_index :decidim_authorizations, :unique_id
  end
end
