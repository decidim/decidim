# frozen_string_literal: true

class AddGroupHighlightEnabledToDecidimOrganizations < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_organizations, :group_highlight_enabled, :boolean, default: false
  end
end
