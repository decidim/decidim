# frozen_string_literal: true

class AllowNullLogoColumnInDecidimConferencesPartnersTable < ActiveRecord::Migration[6.0]
  def change
    change_column_null :decidim_conferences_partners, :logo, true
  end
end
