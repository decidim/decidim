# frozen_string_literal: true

class AddParticipatoryProcessToComments < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_comments_comments, :decidim_participatory_space_type, :string
    add_column :decidim_comments_comments, :decidim_participatory_space_id, :integer

    add_index :decidim_comments_comments,
              [:decidim_participatory_space_id, :decidim_participatory_space_type],
              name: "index_decidim_comments_on_decidim_participatory_space"
  end
end
