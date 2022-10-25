# frozen_string_literal: true

module Decidim
  module Verifications
    module CsvCensus
      module Admin
        # A form to temporaly upload csv census data
        class CensusDataForm < Form
          mimic :census_data

          attribute :file

          def data
            CsvCensus::Data.new(file.path)
          rescue CSV::MalformedCSVError
            errors.add(:file, :malformed)

            nil
          end
        end
      end
    end
  end
end
