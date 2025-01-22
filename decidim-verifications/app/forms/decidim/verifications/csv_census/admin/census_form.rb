# frozen_string_literal: true

module Decidim
  module Verifications
    module CsvCensus
      module Admin
        # A form to temporarily upload csv census data
        class CensusForm < Form
          attribute :email

          validates :email, presence: true
        end
      end
    end
  end
end
