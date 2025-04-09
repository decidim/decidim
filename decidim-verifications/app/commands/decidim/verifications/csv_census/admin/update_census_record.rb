# frozen_string_literal: true

module Decidim
  module Verifications
    module CsvCensus
      module Admin
        # A command with the business logic to create census data for a
        # organization.
        class UpdateCensusRecord < Decidim::Commands::UpdateResource
          fetch_form_attributes :email
        end
      end
    end
  end
end
