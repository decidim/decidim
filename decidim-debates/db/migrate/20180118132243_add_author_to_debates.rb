# frozen_string_literal: true

class AddAuthorToDebates < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_debates_debates, :decidim_author_id, :integer
  end
end
