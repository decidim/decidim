# frozen_string_literal: true

class MakeFeaturesPolymorphic < ActiveRecord::Migration[5.1]
  def change
    remove_index :decidim_features, name: "index_decidim_features_on_decidim_participatory_process_id"

    add_column :decidim_features, :featurable_type, :string

    reversible do |direction|
      direction.up do
        execute <<~SQL.squish
          UPDATE decidim_features
          SET featurable_type = 'Decidim::ParticipatoryProcess'
        SQL
      end
    end

    rename_column :decidim_features, :decidim_participatory_process_id, :featurable_id
    add_index :decidim_features, [:featurable_id, :featurable_type]

    change_column_null :decidim_features, :featurable_id, false
    change_column_null :decidim_features, :featurable_type, false
  end
end
