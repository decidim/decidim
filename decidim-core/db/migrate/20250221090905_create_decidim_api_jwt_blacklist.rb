# frozen_string_literal: true

class CreateDecidimApiJwtBlacklist < ActiveRecord::Migration[7.0]
  def change
    create_table :decidim_api_jwt_blacklists do |t|
      t.string :jti, null: false
      t.datetime :exp, null: false
    end
    add_index :decidim_api_jwt_blacklists, :jti
  end
end
