# frozen_string_literal: true

module Decidim
  module Admin
    module Import
      module Readers
        # Abstract class with a very naive default implementation. Each importable
        # file type should have it's own reader.
        class Base
          # Defines which index of the records defines the first line of actual
          # data. E.g. with spreadsheet formats, the first row contains column
          # name information.
          def self.first_data_index
            0
          end

          def initialize(file)
            @file = file
          end

          # The read_rows method should iterate over each row of the data and
          # yield the data array of each row with the row's index.
          # The first row yielded with index 0 needs to contain the data headers
          # which can be later used to map the data to correct attributes.
          #
          # This needs to be implemented by the extending classes.
          #
          # Returns an array of the import data where the first row should
          # contain the columns.
          def read_rows
            raise NotImplementedError
          end

          # The example_file should produce an example data file for the user to
          # download and take example from to produce their import files. The
          # data provided for the example file generation should be the same as
          # what is returned by the read_rows method.
          #
          # _data - An array of data to produce the file from
          #
          # Returns an IO stream that can be saved to a file or sent to the
          # browser to produce the import file.
          def example_file(_data)
            raise NotImplementedError
          end

          protected

          attr_reader :file
        end
      end
    end
  end
end
