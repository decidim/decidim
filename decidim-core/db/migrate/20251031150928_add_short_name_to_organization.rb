# frozen_string_literal: true

class AddShortNameToOrganization < ActiveRecord::Migration[7.2]
  def change
    add_column :decidim_organizations, :short_name, :jsonb, null: false, default: {}
  end
end
