# frozen_string_literal: true

module Decidim
  module Admin
    module Import
      module Readers
        # Abstract class with a very naive default implementation. Each importable
        # file type should have it's own reader.
        class Base
          class << self
            # Defines which index of the records defines the first line of actual
            # data. E.g. with spreadsheet formats, the first row contains column
            # name information.
            def first_data_index
              0
            end

            def invalid_columns_message_for(columns)
              [
                I18n.t("decidim.admin.imports.invalid_columns.base.message", count: columns.count, columns: humanize_columns(columns)),
                I18n.t("decidim.admin.imports.invalid_columns.base.detail")
              ].join(" ")
            end

            # Creates a message for the provided invalid indexes.
            #
            # Returns a String
            def invalid_indexes_message_for(indexes)
              [
                I18n.t("decidim.admin.imports.invalid_indexes.base.message", count: indexes.count, indexes: humanize_indexes(indexes)),
                I18n.t("decidim.admin.imports.invalid_indexes.base.detail")
              ].join(" ")
            end

            protected

            def humanize_columns(columns)
              return "" if columns.count.zero?
              return columns.first if columns.count == 1

              columns.slice(0, columns.count - 1).push(I18n.t("decidim.admin.imports.invalid_columns.base.and")).push(columns.last).join(" ")
            end

            # Humanizes the index numbers so that it is understandable for humans.
            # Index zero becomes one and the indexes are included in a single
            # string with the last item separated with "and". For instance, for
            # indexes [1, 2, 3] the message would be "1, 2 and 3".
            #
            # Returns a String.
            def humanize_indexes(indexes)
              # Humans don't start counting from zero and this message is shown
              # for humans. This also takes the data start index into account.
              indexes = indexes.map { |i| i + first_data_index + 1 }

              count = indexes.count
              if count > 1
                last = indexes.pop
                "#{indexes.join(", ")} #{I18n.t("decidim.admin.imports.invalid_indexes.base.and")} #{last}"
              else
                indexes.join
              end
            end
          end

          def initialize(file)
            @file = file
          end

          def read_headers
            raise NotImplementedError
          end

          # The read_rows method should iterate over each row of the data and
          # yield the data array of each row with the row's index.
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
