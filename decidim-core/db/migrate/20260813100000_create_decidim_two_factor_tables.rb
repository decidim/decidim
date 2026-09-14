# frozen_string_literal: true

class CreateDecidimTwoFactorTables < ActiveRecord::Migration[7.2]
  def change
    create_table :decidim_two_factor_authenticators do |t|
      t.references :decidim_user, null: false, index: false, foreign_key: { to_table: :decidim_users }
      t.string :type, null: false
      t.string :name
      t.string :secret
      t.string :external_id
      t.string :public_key
      t.bigint :sign_count
      t.bigint :last_used_timestep
      t.jsonb :metadata, null: false, default: {}
      t.datetime :confirmed_at
      t.datetime :last_used_at

      t.timestamps
    end

    add_index :decidim_two_factor_authenticators, :external_id, unique: true
    add_index :decidim_two_factor_authenticators, [:decidim_user_id, :type]

    create_table :decidim_two_factor_recovery_codes do |t|
      t.references :decidim_user, null: false, index: true, foreign_key: { to_table: :decidim_users }
      t.string :code_digest, null: false
      t.datetime :used_at

      t.timestamps
    end

    create_table :decidim_two_factor_challenges do |t|
      t.references :decidim_user, null: false, index: true, foreign_key: { to_table: :decidim_users }
      t.string :method_type, null: false
      t.string :purpose, null: false, default: "login"
      t.string :code_digest
      t.jsonb :metadata, null: false, default: {}
      t.integer :attempts_count, null: false, default: 0
      t.datetime :expires_at, null: false
      t.datetime :consumed_at

      t.timestamps
    end
  end
end
