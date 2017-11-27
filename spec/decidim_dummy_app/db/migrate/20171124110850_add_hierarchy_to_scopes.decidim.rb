# This migration comes from decidim (originally 20170605162500)
# frozen_string_literal: true

class AddHierarchyToScopes < ActiveRecord::Migration[5.0]
  class Scope < ApplicationRecord
    self.table_name = :decidim_scopes
  end

  class Organization < ApplicationRecord
    self.table_name = :decidim_organizations
  end

  def self.up
    # schema migration
    create_table :decidim_scope_types do |t|
      t.references :decidim_organization, foreign_key: true, index: true
      t.jsonb :name, null: false
      t.jsonb :plural, null: false
    end

    # retrieve current data
    current_data = Scope.select(:id, :name, :decidim_organization_id).as_json

    change_table :decidim_scopes do |t|
      t.remove_index :name
      t.remove :name
      t.jsonb :name
      t.references :scope_type, foreign_key: { to_table: :decidim_scope_types }, index: true
      t.references :parent, foreign_key: { to_table: :decidim_scopes }
      t.string :code
      t.integer :part_of, array: true, default: [], null: false
      t.index :part_of, using: "gin"
    end

    current_data.each do |s|
      locales = Organization.find(s["decidim_organization_id"]).available_locales
      name = s["name"].gsub(/'/, "''")
      execute("
        UPDATE decidim_scopes
        SET name = '#{Hash[locales.map { |locale| [locale, name] }].to_json}',
            code = #{quote(s["id"])}
        WHERE id = #{s["id"]}
      ")
    end

    change_column_null :decidim_scopes, :name, false
    change_column_null :decidim_scopes, :code, false
    add_index :decidim_scopes, [:decidim_organization_id, :code], unique: true
  end

  def self.down
    # schema migration
    change_table :decidim_scopes do |t|
      t.remove_index [:decidim_organization_id, :code]
      t.change :name, :string, null: false, index: :uniqueness
      t.remove :scope_type_id, :parent_id, :code, :part_of
    end
    add_index :decidim_scopes, :name, unique: true
    drop_table :decidim_scope_types

    # post migration data fixes
    Scope.select(:id, :name).as_json.each do |s|
      name = quote(JSON.parse(s["name"]).values.first)
      execute("
        UPDATE decidim_scopes
        SET name = #{name}
        WHERE id = #{s["id"]}
      ")
    end
  end
end
