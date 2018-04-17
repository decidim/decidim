# frozen_string_literal: true

class AddParentChildRelationToAssemblies < ActiveRecord::Migration[5.1]
  def change
    unless extension_enabled?("ltree")
      begin
        # required so that test suite works in ci env
        enable_extension "ltree"
      rescue StandardError
        raise <<-MSG.squish
        Decidim requires the ltree extension to be enabled in your PostgreSQL.
        You can do so by running `CREATE EXTENSION IF NOT EXISTS "ltree";` on the current DB as a PostgreSQL
        super user.
        MSG
      end
    end

    add_reference :decidim_assemblies, :parent, index: { name: :decidim_assemblies_assemblies_on_parent_id }
    add_column :decidim_assemblies, :parents_path, :ltree
    add_column :decidim_assemblies, :children_count, :integer, default: 0
  end
end
