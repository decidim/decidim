# frozen_string_literal: true

module Decidim
  module Verifications
    module CsvCensus
      class Status
        def initialize(organization)
          @organization = organization
        end

        def last_import_at
          @last ||= CsvDatum.inside(@organization)
                            .order(created_at: :desc).first
          @last ? @last.created_at : nil
        end

        def count
          @count ||= CsvDatum.inside(@organization)
                             .distinct.count(:email)
        end
      end
    end
  end
end
