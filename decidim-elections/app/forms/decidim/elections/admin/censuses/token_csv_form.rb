# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      module Censuses
        class TokenCsvForm < Decidim::Form
          include Decidim::HasUploadValidations
          # include Decidim::Admin::CustomImport

          # mimic :census_data

          attribute :file, Decidim::Attributes::Blob
          attribute :remove_all, Boolean

          validates :file, presence: true, file_content_type: { allow: ["text/csv"] }, if: ->(form) { form.remove_all.blank? }

          def parse_csv_data
            return @csv_data if defined?(@csv_data)
            return nil if file.blank?

            file_io = StringIO.new(file.download)
            @csv_data = CsvCensus::Data.new(file_io)
          rescue CSV::MalformedCSVError
            errors.add(:file, :malformed)
            @csv_data = nil
          end

          def data
            parse_csv_data&.values || []
          end

          def errors_data
            parse_csv_data&.errors || []
          end
        end
      end
    end
  end
end
