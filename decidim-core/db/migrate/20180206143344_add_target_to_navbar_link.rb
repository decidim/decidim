# frozen_string_literal: true

class AddTargetToNavbarLink < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_navbar_links, :target, :string
  end
end
