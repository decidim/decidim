# frozen_string_literal: true

require "csv"

module Decidim
  module Admin
    module Import
      module Readers
        # Imports any exported CSV file to local objects. It transforms the
        # import data using the creator into the final target objects.
        class CSV < Base
          MIME_TYPE = "text/csv"

          def read_rows
            ::CSV.read(file, col_sep: ";").each_with_index do |row, index|
              yield row, index
            end
          end
        end
      end
    end
  end
end
