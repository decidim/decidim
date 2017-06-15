class AddHierarchyToScopes   < ActiveRecord::Migration[5.0]
  def self.up
    # schema migration
    create_table :decidim_scope_types do |t|
      t.references :decidim_organization, foreign_key: true, index: true
      t.jsonb :name, null: false
      t.jsonb :plural, null: false
    end

    change_table :decidim_scopes do |t|
      t.remove_index :name
      t.jsonb :name2, null: false
      t.references :scope_type, foreign_key: { to_table: :decidim_scope_types }, index: true
      t.references :parent, foreign_key: { to_table: :decidim_scopes }
      t.string :code
      t.jsonb :metadata, default: {}, null: false
      t.boolean :deprecated, default: false, null: false
      t.integer :part_of, array: true, default: [], null: false
      t.index :part_of, using: 'gin'
    end

    # post migration data fixes
    Decidim::Scope.all.find_each do |s|
      s.name2 = Hash[s.organization.available_locales.map{|lo| [lo, s.name]} ]
      s.code = s.id.to_s
      s.save!
    end

    # post data migration schema fixes
    change_table :decidim_scopes do |t|
      t.remove :name
      t.rename :name2, :name
      t.index [ :decidim_organization_id, :code ], unique: true
    end
    change_column_null :decidim_scopes, :code, false
    change_column_null :decidim_scopes, :metadata, false
    change_column_null :decidim_scopes, :deprecated, false


    Decidim::Scope.reset_column_information
  end

  def self.down
    # schema migration
    change_table :decidim_scopes do |t|
      t.remove_index [ :organization, :code ], unique: true
      t.remove :scope_type_id, :code, :part_of, :metadata, :deprecated
      t.change :name, :string, null: false
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
