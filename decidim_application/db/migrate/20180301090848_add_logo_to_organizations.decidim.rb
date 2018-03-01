# This migration comes from decidim (originally 20161214152811)
# frozen_string_literal: true

class AddLogoToOrganizations < ActiveRecord::Migration[5.0]
  def change
    add_column :decidim_organizations, :logo, :string
  end
end
