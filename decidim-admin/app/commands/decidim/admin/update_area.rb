# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic when updating an area.
    class UpdateArea < Decidim::Commands::UpdateResource
      fetch_form_attributes :name, :area_type
    end
  end
end
