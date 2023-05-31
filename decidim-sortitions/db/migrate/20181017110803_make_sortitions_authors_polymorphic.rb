# frozen_string_literal: true

class MakeSortitionsAuthorsPolymorphic < ActiveRecord::Migration[5.2]
  class User < ApplicationRecord
    self.table_name = :decidim_users
    self.inheritance_column = nil # disable the default inheritance

    default_scope { where(type: "Decidim::User") }
  end

  class Sortition < ApplicationRecord
    include Decidim::HasComponent

    self.table_name = :decidim_sortitions_sortitions
  end

  def change
    add_column :decidim_sortitions_sortitions, :decidim_author_type, :string

    Sortition.find_each do |sortition|
      author = User.find_by(id: sortition.decidim_author_id) if sortition.decidim_author_id.present?
      author ||= sortition.organization
      sortition.update!(
        decidim_author_type: author.is_a?(User) ? author.type : "Decidim::Organization",
        decidim_author_id: author.id
      )
    end

    add_index :decidim_sortitions_sortitions,
              [:decidim_author_id, :decidim_author_type],
              name: "index_decidim_sortitions_sortitions_on_decidim_author"
    change_column_null :decidim_sortitions_sortitions, :decidim_author_id, false
    change_column_null :decidim_sortitions_sortitions, :decidim_author_type, false
  end
end
