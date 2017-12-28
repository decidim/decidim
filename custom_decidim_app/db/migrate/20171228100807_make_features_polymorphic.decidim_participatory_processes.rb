# This migration comes from decidim_participatory_processes (originally 20170720120135)
# frozen_string_literal: true

class MakeFeaturesPolymorphic < ActiveRecord::Migration[5.1]
  def change
    remove_index :decidim_features, name: "index_decidim_features_on_decidim_participatory_process_id"

    add_column :decidim_features, :participatory_space_type, :string

    reversible do |direction|
      direction.up do
        execute <<~SQL.squish
          UPDATE decidim_features
          SET participatory_space_type = 'Decidim::ParticipatoryProcess'
        SQL
      end
    end

    rename_column :decidim_features, :decidim_participatory_process_id, :participatory_space_id

    add_index :decidim_features,
              [:participatory_space_id, :participatory_space_type],
              name: "index_decidim_features_on_decidim_participatory_space"

    change_column_null :decidim_features, :participatory_space_id, false
    change_column_null :decidim_features, :participatory_space_type, false
  end
end
