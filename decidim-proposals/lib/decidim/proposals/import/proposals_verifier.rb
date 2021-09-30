# frozen_string_literal: true

module Decidim
  module Proposals
    module Import
      # This class is responsible for verifying the data for proposals import.
      class ProposalsVerifier < Decidim::Admin::Import::Verifier
        protected

        def required_headers
          required_localized_headers("title") + required_localized_headers("body")
        end
      end
    end
  end
end
