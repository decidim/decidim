# frozen_string_literal: true

class RenameDoorkeeperScopes < ActiveRecord::Migration[7.0]
  def up
    tables.each { |table| update_scopes(table, "profile", "public") }
  end

  def down
    tables.each { |table| update_scopes(table, "public", "profile") }
  end

  private

  def update_scopes(table, new_value, old_value)
    tbl = Arel::Table.new(table)
    um = Arel::UpdateManager.new(tbl)
    um.set([[tbl[:scopes], new_value]])
    um.where(tbl[:scopes].eq(old_value))
    execute um.to_sql
  end

  def tables
    [:oauth_applications, :oauth_access_grants, :oauth_access_tokens]
  end
end
