# frozen_string_literal: true

class AddParentChildRelationToAssemblies < ActiveRecord::Migration[5.0]
  def change
    enable_extension "ltree"

    add_reference :decidim_assemblies, :parent, index: { name: :decidim_assemblies_assemblies_on_parent_id }
    add_column :decidim_assemblies, :parents_path, :ltree
    add_column :decidim_assemblies, :children_count, :integer, default: 0
  end
end
