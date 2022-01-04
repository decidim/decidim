# frozen_string_literal: true

module Decidim
  module Budgets
    module Import
      # This class is responsible for creating the imported paper ballot results
      # and must be included in budgets component's import manifest.
      class PaperBallotResultCreator < Decidim::Admin::Import::Creator
        # Retuns the resource class to be created with the provided data.
        def self.resource_klass
          Decidim::Budgets::PaperBallotResult
        end

        # Returns a verifier class to be used to verify the correctness of the
        # import data.
        def self.verifier_klass
          Decidim::Budgets::Import::PaperBallotResultVerifier
        end

        # Produces a paper ballot result from parsed data
        #
        # Returns a paper ballot result
        def produce
          resource
        end

        # Saves the paper ballot result
        def finish!
          super # resource.save!
        end

        private

        def resource
          @resource ||= Decidim::Budgets::PaperBallotResult.new(
            votes: votes,
            decidim_project_id: id
          )
        end

        def votes
          data[:new_paper_ballots].to_i
        end

        def id
          data[:id].to_i
        end
      end
    end
  end
end
