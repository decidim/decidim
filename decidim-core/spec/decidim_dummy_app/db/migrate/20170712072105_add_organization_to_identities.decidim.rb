# This migration comes from decidim (originally 20170405094028)
# frozen_string_literal: true

class AddOrganizationToIdentities < ActiveRecord::Migration[5.0]
  def change
    add_reference :decidim_identities, :decidim_organization, index: true, foreign_key: true
  end
end
