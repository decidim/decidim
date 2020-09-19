# frozen_string_literal: true

class CreateDecidimShareTokens < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_share_tokens do |t|
      t.references :decidim_organization, null: false, index: true
      t.references :decidim_user, null: false, index: true
      t.references :token_for, polymorphic: true, null: false, index: { name: "decidim_share_tokens_token_for" }
      t.string :token, null: false
      t.integer :times_used, default: 0
      t.datetime :created_at
      t.datetime :last_used_at
      t.datetime :expires_at
    end
  end
end
