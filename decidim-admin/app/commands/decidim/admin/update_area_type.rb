# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic when updating an area type.
    class UpdateAreaType < Decidim::Commands::UpdateResource
      fetch_form_attributes :name, :plural
    end
  end
end
