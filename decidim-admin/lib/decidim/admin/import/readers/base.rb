# frozen_string_literal: true

module Decidim
  module Admin
    module Import
      module Readers
        # Imports an exported file to data arrays that can be processed during
        # yields.
        class Base
          def initialize(file)
            @file = file
          end

          # The read_rows method should iterate over each row of the data and
          # yield the data array of each row with the row's index. For example,
          # this could look like following:
          #   Parser.read(file).rows.each_with_index do |row, index|
          #     yield row.to_a, index
          #   end
          #
          # The first row yielded with index 0 needs to contain the data headers
          # which can be later used to map the data to correct attributes.
          #
          # This needs to be implemented by the extending classes.
          def read_rows
            raise NotImplementedError
          end

          protected

          attr_reader :file
        end
      end
    end
  end
end
