# frozen_string_literal: true

module Decidim
  module Votings
    module Census
      class Datum < ApplicationRecord
        include Decidim::RecordEncryptor

        encrypt_attribute :document_number, type: :string
        encrypt_attribute :document_type, type: :string
        encrypt_attribute :birthdate, type: :string
        encrypt_attribute :full_name, type: :string
        encrypt_attribute :full_address, type: :string
        encrypt_attribute :postal_code, type: :string
        encrypt_attribute :mobile_phone_number, type: :string
        encrypt_attribute :email, type: :string

        belongs_to :dataset, foreign_key: "decidim_votings_census_dataset_id",
                             class_name: "Decidim::Votings::Census::Dataset"

        belongs_to :voting, foreign_key: "decidim_votings_voting_id",
                            class_name: "Decidim::Votings::Voting"

        validates :document_number,
                  :document_type,
                  :birthdate,
                  :full_name,
                  :full_address,
                  :postal_code,
                  presence: true

        # validates :email, format: { with: ::Devise.email_regexp }
        validates :document_number, uniqueness: { scope: :voting }
      end
    end
  end
end
