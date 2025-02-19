# frozen_string_literal: true

module Decidim
  module Verifications
    module CsvCensus
      module Admin
        # A form to temporarily upload csv census data
        class CensusForm < Form
          attribute :email, String

          validates :email, presence: true, "valid_email_2/email": { disposable: true }
        end
      end
    end
  end
end
