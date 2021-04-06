# frozen_string_literal: true

module Decidim
  module Votings
    # A form to check if data matches census
    class CheckCensusForm < Form
      attribute :document_number, String
      attribute :document_type, String
      attribute :postal_code, String
      attribute :day, String
      attribute :month, String
      attribute :year, String

      validates :document_number,
                :document_type,
                :postal_code,
                presence: true

      def options_for_document_type_select
        [
          I18n.t("passport", scope: "decidim.votings.votings.check_census_form"),
          I18n.t("dni", scope: "decidim.votings.votings.check_census_form")
        ]
      end

      def birthdate
        year + month + day
      end

      # hash of document number, document type, birthdate
      # and postal code to check if census is in dataset
      def hashed_check_data
        hash_for [document_number, document_type, birthdate, postal_code]
      end

      def hash_for(data)
        Digest::SHA256.hexdigest(data.join("."))
      end
    end
  end
end
