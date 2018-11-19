# frozen_string_literal: true

class MakeInitiativeAuthorsPolymorphic < ActiveRecord::Migration[5.2]
  class Initiative < ApplicationRecord
    self.table_name = :decidim_initiatives
  end

  def change
    remove_index :decidim_initiatives, :decidim_author_id

    add_column :decidim_initiatives, :decidim_author_type, :string

    reversible do |direction|
      direction.up do
        execute <<~SQL.squish
          UPDATE decidim_initiatives
          SET decidim_author_type = 'Decidim::UserBaseEntity'
        SQL
      end
    end

    add_index :decidim_initiatives,
              [:decidim_author_id, :decidim_author_type],
              name: "index_decidim_initiatives_on_decidim_author"

    change_column_null :decidim_initiatives, :decidim_author_id, false
    change_column_null :decidim_initiatives, :decidim_author_type, false

    Initiative.reset_column_information
  end
end
