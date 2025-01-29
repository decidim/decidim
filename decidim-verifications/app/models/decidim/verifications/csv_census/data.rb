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
      # - .values an array with emails read from the csv file
      #
      # Returns nothing
      class Data
        attr_reader :errors, :values

        def initialize(file)
          @file = file
          @values = []
          @errors = []
          @column_count = nil

          CSV.foreach(@file, encoding: "BOM|UTF-8") do |row|
            process_row(row)
            @column_count ||= row.size
          end

          @errors << I18n.t("decidim.verifications.errors.wrong_number_columns", expected: 1, actual: @column_count) if @column_count && @column_count > 1
        end

        def count
          @column_count || 0
        end

        def headers
          first_row = CSV.open(@file, encoding: "BOM|UTF-8", &:first)

          return [] unless first_row

          return [] if valid_email?(first_row.first)

          errors << I18n.t("decidim.verifications.errors.has_headers")
          return first_row.map(&:strip)
        end

        private

        def valid_email?(email)
          email.present? && email.match?(::Devise.email_regexp)
        end

        def process_row(row)
          user_mail = row.first
          if user_mail.present? && user_mail.match?(::Devise.email_regexp)
            values << user_mail
          else
            errors << row
          end
        end
      end
    end
  end
end
