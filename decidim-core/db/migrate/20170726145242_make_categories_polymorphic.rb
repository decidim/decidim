# frozen_string_literal: true

class MakeCategoriesPolymorphic < ActiveRecord::Migration[5.1]
  def change
    remove_index :decidim_categories,
                 name: "index_decidim_categories_on_decidim_participatory_process_id"

    add_column :decidim_categories, :decidim_featurable_type, :string

    reversible do |direction|
      direction.up do
        execute <<~SQL.squish
          UPDATE decidim_categories
          SET decidim_featurable_type = 'Decidim::ParticipatoryProcess'
        SQL
      end
    end

    rename_column :decidim_categories,
                  :decidim_participatory_process_id,
                  :decidim_featurable_id

    add_index :decidim_categories,
              [:decidim_featurable_id, :decidim_featurable_type],
              name: "decidim_categories_featurable_id_and_type"
  end
end
