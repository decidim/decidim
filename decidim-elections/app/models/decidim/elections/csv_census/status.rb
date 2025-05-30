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
      end
    end
  end
end
