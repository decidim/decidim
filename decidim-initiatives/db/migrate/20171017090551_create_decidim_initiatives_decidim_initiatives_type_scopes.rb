# frozen_string_literal: true

class CreateDecidimInitiativesDecidimInitiativesTypeScopes < ActiveRecord::Migration[5.1]
  def change
    create_table :decidim_initiatives_type_scopes do |t|
      t.references :decidim_initiatives_types, index: { name: "idx_scoped_initiative_type_type" }
      t.references :decidim_scopes, index: { name: "idx_scoped_initiative_type_scope" }
      t.integer :supports_required, null: false

      t.timestamps
    end
  end
end
