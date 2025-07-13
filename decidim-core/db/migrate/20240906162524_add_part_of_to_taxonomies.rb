# frozen_string_literal: true

class AddPartOfToTaxonomies < ActiveRecord::Migration[7.0]
  class Taxonomy < ApplicationRecord
    self.table_name = :decidim_taxonomies
    belongs_to :parent, class_name: "Taxonomy", optional: true
  end

  def change
    add_column :decidim_taxonomies, :part_of, :integer, array: true, default: [], null: false
    add_index :decidim_taxonomies, :part_of, using: "gin"

    reversible do |dir|
      dir.up do
        Taxonomy.find_each do |taxonomy|
          if taxonomy.parent
            taxonomy.part_of.clear.append(taxonomy.id).concat(taxonomy.parent.reload.part_of)
          else
            taxonomy.part_of.clear.append(taxonomy.id)
          end
          taxonomy.save
        end
      end
    end
  end
end
