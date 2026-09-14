# frozen_string_literal: true

class AddTwoFactorFieldsToDecidimOrganizations < ActiveRecord::Migration[7.2]
  def change
    add_column :decidim_organizations, :two_factor_authentication_enabled, :boolean, null: false, default: false
    add_column :decidim_organizations, :two_factor_enforced_for, :string, null: false, default: "none"
    add_column :decidim_organizations, :two_factor_enforced_at, :datetime
    add_column :decidim_organizations, :available_two_factor_methods, :string, array: true, default: []
    add_column :decidim_organizations, :two_factor_grace_period_days, :integer
  end
end
