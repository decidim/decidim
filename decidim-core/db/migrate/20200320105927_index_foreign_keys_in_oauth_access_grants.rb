# frozen_string_literal: true

class IndexForeignKeysInOAuthAccessGrants < ActiveRecord::Migration[5.2]
  def change
    add_index :oauth_access_grants, :resource_owner_id
  end
end
