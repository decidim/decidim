# frozen_string_literal: true

class AddAncestorsPathToAssemblies < ActiveRecord::Migration[5.0]
  def change
    add_column :decidim_assemblies, :parents_path, :ltree
  end
end

