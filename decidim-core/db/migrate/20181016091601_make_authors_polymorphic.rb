# frozen_string_literal: true

class MakeAuthorsPolymorphic < ActiveRecord::Migration[5.2]
  class Coauthorship < ApplicationRecord
    self.table_name = :decidim_coauthorships
  end

  def change
    remove_index :decidim_coauthorships, :decidim_author_id

    add_column :decidim_coauthorships, :decidim_author_type, :string

    reversible do |direction|
      direction.up do
        execute <<~SQL.squish
          UPDATE decidim_coauthorships
          SET decidim_author_type = 'Decidim::UserBaseEntity'
        SQL
      end
    end

    add_index :decidim_coauthorships,
              [:decidim_author_id, :decidim_author_type],
              name: "index_decidim_coauthorships_on_decidim_author"

    change_column_null :decidim_coauthorships, :decidim_author_id, false
    change_column_null :decidim_coauthorships, :decidim_author_type, false

    Coauthorship.reset_column_information
  end
end
