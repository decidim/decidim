# This migration comes from decidim (originally 20161209134715)
# frozen_string_literal: true

class MakeOrganizationDescriptionOptional < ActiveRecord::Migration[5.0]
  def change
    change_column :decidim_organizations, :welcome_text, :jsonb, null: true
  end
end
