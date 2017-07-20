# frozen_string_literal: true

class MakeModerationsPolymorphic < ActiveRecord::Migration[5.1]
  def change
    remove_index :decidim_moderations,
                 name: "decidim_moderations_participatory_process"

    add_column :decidim_moderations, :decidim_featurable_type, :string

    reversible do |direction|
      direction.up do
        execute <<~SQL.squish
          UPDATE decidim_moderations
          SET decidim_featurable_type = 'Decidim::ParticipatoryProcess'
        SQL
      end
    end

    rename_column :decidim_moderations,
                  :decidim_participatory_process_id,
                  :decidim_featurable_id

    add_index :decidim_moderations,
              [:decidim_featurable_id, :decidim_featurable_type],
              name: "decidim_moderations_featurable"

    change_column_null :decidim_moderations, :decidim_featurable_type, false
  end
end
