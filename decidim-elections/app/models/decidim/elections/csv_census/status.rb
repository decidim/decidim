# frozen_string_literal: true

module Decidim
  module Elections
    module CsvCensus
      class Status
        def initialize(election)
          @election = election
        end

        def last_import_at
          @last ||= Voter.inside(@election).order(created_at: :desc).first
          @last ? @last.created_at : nil
        end

        def count(attribute = :email)
          Voter.inside(@election).distinct.count(attribute)
        end

        def to_json(*)
          {
            name:,
            count:,
            electionId: @election.id,
            lastImportAt: last_import_at
          }.to_json
        end

        def name
          if pending_upload?
            "pending_upload"
          else
            "ready"
          end
        end

        def pending_upload?
          count.zero?
        end

        def ready_to_setup?
          return true if (@election.internal_census? && @election.verification_types.empty?) ||
                         (@election.internal_census? && count.zero?)

          count.positive?
        end
      end
    end
  end
end
