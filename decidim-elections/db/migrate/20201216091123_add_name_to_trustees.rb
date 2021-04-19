# frozen_string_literal: true

class AddNameToTrustees < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_elections_trustees, :name, :string, null: true, unique: true
  end
end
