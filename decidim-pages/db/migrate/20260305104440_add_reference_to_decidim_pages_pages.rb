# frozen_string_literal: true

class AddReferenceToDecidimPagesPages < ActiveRecord::Migration[8.0]
  def change
    add_column :decidim_pages_pages, :reference, :string
  end
end
