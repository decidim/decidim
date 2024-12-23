# frozen_string_literal: true

class AddTaxonomyToInitiativesTypeScope < ActiveRecord::Migration[7.0]
  def change
    add_reference :decidim_initiatives_type_scopes, :decidim_taxonomy, index: true
  end
end
