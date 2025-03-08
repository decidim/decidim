# frozen_string_literal: true

class AddCommentsLayoutToDebates < ActiveRecord::Migration[7.0]
  def change
    add_column :decidim_debates_debates, :comments_layout, :string
  end
end
