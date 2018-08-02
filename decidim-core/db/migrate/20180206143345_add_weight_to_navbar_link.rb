# frozen_string_literal: true

class AddWeightToNavbarLink < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_navbar_links, :weight, :integer
  end
end
