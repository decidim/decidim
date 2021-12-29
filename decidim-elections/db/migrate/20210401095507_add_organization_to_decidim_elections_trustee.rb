# frozen_string_literal: true

class AddOrganizationToDecidimElectionsTrustee < ActiveRecord::Migration[5.2]
  def change
    add_reference :decidim_elections_trustees, :decidim_organization, index: true, foreign_key: true
    add_index :decidim_elections_trustees,
              [:name, :decidim_organization_id],
              unique: true,
              name: "index_decidim_organization_id_and_name"
  end
end
