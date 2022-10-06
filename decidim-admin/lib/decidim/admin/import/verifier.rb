# frozen_string_literal: true

module Decidim
  module Admin
    module Import
      # This is the default verifier class that verifies the import data is
      # valid before starting the import process. It makes sure the data is in
      # correct format, contains the correct data headers, etc.
      #
      # Individual importers can extend this class to customize the verification
      # process.
      class Verifier
        include ActiveModel::Validations

        validate :validate_headers
        validate :validate_data, if: -> { errors.blank? }

        # Public: Initializes an Importer.
        #
        # headers - An array of the data headers for the import.
        # data - An array of the generated data records to be imported.
        # reader - A Reader class that was used to read the raw data.
        # context - A hash including component specific data.
        def initialize(headers:, data:, reader:, context: nil)
          @headers = headers
          @data = data
          @reader = reader
          @context = context
        end

        protected

        attr_reader :headers, :data, :reader, :context

        def validate_headers
          if missing_headers.any?
            message = [
              I18n.t(
                "decidim.admin.imports.data_errors.missing_headers.message",
                count: missing_headers.count,
                columns: humanize_list(missing_headers)
              ),
              I18n.t("decidim.admin.imports.data_errors.missing_headers.detail")
            ].join(" ")

            errors.add(:headers, message)
          end

          return unless duplicate_headers.any?

          message = [
            I18n.t(
              "decidim.admin.imports.data_errors.duplicate_headers.message",
              count: duplicate_headers.count,
              columns: humanize_list(duplicate_headers)
            ),
            I18n.t("decidim.admin.imports.data_errors.duplicate_headers.detail")
          ].join(" ")

          errors.add(:headers, message)
        end

        def validate_data
          return if invalid_indexes.empty?

          indexes = humanize_indexes(invalid_indexes, reader.first_data_index)
          message =
            if reader.first_data_index.zero?
              # If the data starts from index zero we don't want to say to the
              # user that there are errors on "rows". We want to refer to record
              # numbers instead. This is the case e.g. with JSON data format.
              [
                I18n.t(
                  "decidim.admin.imports.data_errors.invalid_indexes.records.message",
                  count: invalid_indexes.count,
                  indexes:
                ),
                I18n.t("decidim.admin.imports.data_errors.invalid_indexes.records.detail")
              ].join(" ")
            else
              [
                I18n.t(
                  "decidim.admin.imports.data_errors.invalid_indexes.lines.message",
                  count: invalid_indexes.count,
                  indexes:
                ),
                I18n.t("decidim.admin.imports.data_errors.invalid_indexes.lines.detail")
              ].join(" ")
            end

          errors.add(:data, message)
        end

        def available_locales
          @available_locales ||= context[:current_organization]&.available_locales || I18n.available_locales.map(&:to_s)
        end

        def default_locale
          @default_locale ||= context[:current_organization]&.default_locale || I18n.default_locale.to_s
        end

        # Individual verifier classes can extend this to provide their required
        # headers.
        #
        # Returns an array of required headers.
        def required_headers
          []
        end

        def required_localized_headers(name)
          ["#{name}/#{default_locale}"]
        end

        def missing_headers
          @missing_headers ||= [].tap do |array|
            required_headers.each do |required|
              array << required unless headers.include?(required)
            end
          end
        end

        def duplicate_headers
          @duplicate_headers ||= headers.select { |e| headers.count(e) > 1 }.uniq
        end

        # Returns array of all resource indexes where validations fail.
        def invalid_indexes
          @invalid_indexes ||= [].tap do |indexes|
            data.each_with_index do |record, index|
              indexes << index unless valid_record?(record)
            end
          end
        end

        # Validates the record and allows individual verifiers to customize the
        # validation logic by overriding this method.
        #
        # Returns a boolean indicating whether the record to be imported is
        # valid.
        def valid_record?(record)
          record.valid?
        end

        # Humanizes the index numbers so that it is understandable for humans.
        # Index zero becomes one and the indexes are included in a single
        # string with the last item separated with "and". For instance, for
        # indexes [1, 2, 3] the message would be "1, 2 and 3".
        #
        # Returns a String.
        def humanize_indexes(indexes, start_index)
          # Humans don't start counting from zero and this message is shown
          # for humans. This also takes the data start index into account.
          indexes = indexes.map { |i| i + start_index + 1 }

          humanize_list(indexes)
        end

        def humanize_list(list)
          if list.count > 1
            last = list.pop
            "#{list.join(", ")} #{I18n.t("decidim.admin.imports.and")} #{last}"
          else
            list.join
          end
        end
      end
    end
  end
end
