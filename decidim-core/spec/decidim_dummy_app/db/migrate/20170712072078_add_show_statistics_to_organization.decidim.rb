# This migration comes from decidim (originally 20170119150649)
# frozen_string_literal: true

class AddShowStatisticsToOrganization < ActiveRecord::Migration[5.0]
  def change
    add_column :decidim_organizations, :show_statistics, :boolean, default: true
  end
end
