# frozen_string_literal: true

module Decidim
  module Proposals
    module Import
      # This class is responsible for verifying the data for proposal answers
      # import.
      class ProposalsAnswersVerifier < Decidim::Admin::Import::Verifier
        protected

        def required_headers
          %w(id state) + required_localized_headers("answer")
        end

        # Check if prepared resource is valid
        #
        # record - Decidim::Proposals::Proposal
        #
        # Returns true if record is valid
        def valid_record?(record)
          return false if record.nil?
          return false if record.errors.any?

          record.valid?
        end
      end
    end
  end
end
