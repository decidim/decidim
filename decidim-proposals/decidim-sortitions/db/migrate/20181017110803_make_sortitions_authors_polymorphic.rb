# frozen_string_literal: true

class MakeSortitionsAuthorsPolymorphic < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_sortitions_sortitions, :decidim_author_type, :string

    Decidim::Sortitions::Sortition.reset_column_information
    Decidim::Sortitions::Sortition.includes(:author).find_each do |sortition|
      author = if sortition.decidim_author_id.present?
                 Decidim::User.find(sortition.decidim_author_id)
               else
                 sortition.organization
               end
      sortition.author = author
      sortition.save!
    end

    add_index :decidim_sortitions_sortitions,
              [:decidim_author_id, :decidim_author_type],
              name: "index_decidim_sortitions_sortitions_on_decidim_author"
    change_column_null :decidim_sortitions_sortitions, :decidim_author_id, false
    change_column_null :decidim_sortitions_sortitions, :decidim_author_type, false
  end
end
