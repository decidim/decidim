# frozen_string_literal: true

require "spreadsheet"

module Decidim
  module Admin
    module Import
      module Readers
        # Imports any exported XLS file to local objects. It transforms the
        # import data using the creator into the final target objects.
        class XLS < Base
          MIME_TYPE = "application/vnd.ms-excel"

          def read_rows
            book = ::Spreadsheet.open(file)
            sheet = book.worksheet(0)
            sheet.each_with_index do |row, index|
              yield row.to_a, index
            end
          end
        end
      end
    end
  end
end
