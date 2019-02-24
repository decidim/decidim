# frozen_string_literal: true

require "csv"

module Decidim
  module Verifications
    module CsvCensus
      # A data processor for get emails data form a csv file
      #
      # Enable this methods:
      #
      # - .error with an array of rows with errors in the csv file
      # - .values an array with emails readed from the csv file
      #
      # Returns nothing
      class Data
        attr_reader :errors, :values
        def initialize(file)
          @file = file
          @values = []
          @errors = []

          CSV.foreach(@file, headers: true) do |row|
            process_row(row)
          end
        end

        private

        def process_row(row)
          user_mail = row["email"]
          if user_mail.present?
            values << user_mail
          else
            errors << row
          end
        end
      end
    end
  end
end
