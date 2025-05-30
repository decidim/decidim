# frozen_string_literal: true

require "csv"

module Decidim
  module Elections
    module CsvCensus
      class Data
        attr_reader :values, :errors

        def initialize(file)
          @values = []
          @errors = []
          @seen_emails = Set.new

          CSV.foreach(file, col_sep: ";", headers: true, encoding: "BOM|UTF-8") do |row|
            process_row(row)
          end
        end

        private

        def process_row(row)
          email = row["email"]&.strip
          token = row["token"]&.strip

          return if duplicate?(email)
          return errors << row if invalid?(email, token)

          values << [email, token]
        end

        def invalid?(email, token)
          email.blank? || token.blank? || !email.match?(::Devise.email_regexp)
        end

        def duplicate?(email)
          !@seen_emails.add?(email)
        end
      end
    end
  end
end
