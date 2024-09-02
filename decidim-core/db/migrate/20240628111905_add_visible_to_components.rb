# frozen_string_literal: true

class AddVisibleToComponents < ActiveRecord::Migration[7.0]
  def change
    add_column :decidim_components, :visible, :boolean, default: true
  end
end
