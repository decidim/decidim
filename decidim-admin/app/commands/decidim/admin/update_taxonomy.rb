# frozen_string_literal: true

module Decidim
  module Admin
    # A command to update a taxonomy.
    class UpdateTaxonomy < Decidim::Commands::UpdateResource
      fetch_form_attributes :name, :parent_id
    end
  end
end
