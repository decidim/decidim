# frozen_string_literal: true

require "csv"

module Decidim
  module Verifications
    module CsvCensus
      class Data
        attr_reader :errors, :values
        def initialize(file)
          @file = file
          @errors = []
          @values = []

          CSV.foreach(@file, headers: true) do |row|
            process_row(row)
          end
        end

        private

        def process_row(row)
          user_mail = row[0]
          values << row if user_mail.present?
        end
      end
    end
  end
end
