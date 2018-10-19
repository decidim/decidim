# frozen_string_literal: true

class AddOrganizationAsAuthorToDebates < ActiveRecord::Migration[5.2]
  class Debate < ApplicationRecord
    self.table_name = :decidim_debates_debates
  end
  class User < ApplicationRecord
    self.table_name = :decidim_users
  end
  def change
    add_column :decidim_debates_debates, :decidim_author_type, :string

    Debate.reset_column_information
    Debate.includes(:author).find_each do |debate|
      author = if debate.decidim_author_id.present?
                 User.find(debate.decidim_author_id)
               else
                 debate.organization
               end
      debate.author = author
      debate.save!
    end

    add_index :decidim_debates_debates,
              [:decidim_author_id, :decidim_author_type],
              name: "index_decidim_debates_debates_on_decidim_author"
    change_column_null :decidim_debates_debates, :decidim_author_id, false
    change_column_null :decidim_debates_debates, :decidim_author_type, false
  end
end
