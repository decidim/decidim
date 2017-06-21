# frozen_string_literal: true

class AddHierarchyToScopes < ActiveRecord::Migration[5.0]
  def self.up
    # schema migration
    create_table :decidim_scope_types do |t|
      t.references :decidim_organization, foreign_key: true, index: true
      t.jsonb :name, null: false
      t.jsonb :plural, null: false
    end

    # retrieve current data
    current_data = Decidim::Scope.select(:id, :name).as_json

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
    Decidim::Scope.reset_column_information

    current_data.each do |s|
      Decidim::Scope.update(s["id"],
                            name: Hash[organization.available_locales.map { |lo| [lo, s["name"]] }],
                            code: s["id"].to_s)
    end

    change_column_null :decidim_scopes, :name, false
    change_column_null :decidim_scopes, :code, false
    add_index :decidim_scopes, [:decidim_organization_id, :code], unique: true
  end

  def self.down
    # schema migration
    change_table :decidim_scopes do |t|
      t.remove_index [:organization, :code], unique: true
      t.change :name, :string, null: false
      t.remove :scope_type, :parent, :code, :part_of
    end
    remove_table :decidim_scope_types

    # post migration data fixes
    Decidim::Scope.reset_column_information
    Decidim::Scope.all.find_each do |s|
      s.name = JSON.parse(s.name).values.first
      s.save!
    end
  end
end
