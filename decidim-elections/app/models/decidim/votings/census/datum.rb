# frozen_string_literal: true

module Decidim
  module Votings
    module Census
      class Datum < ApplicationRecord
        include Decidim::RecordEncryptor

        encrypt_attribute :full_name, type: :string
        encrypt_attribute :full_address, type: :string
        encrypt_attribute :postal_code, type: :string
        encrypt_attribute :mobile_phone_number, type: :string
        encrypt_attribute :email, type: :string

        belongs_to :dataset, foreign_key: "decidim_votings_census_dataset_id",
                             class_name: "Decidim::Votings::Census::Dataset"

        belongs_to :voting, foreign_key: "decidim_votings_voting_id",
                            class_name: "Decidim::Votings::Voting"

        validates :full_name,
                  :full_address,
                  :postal_code,
                  :hashed_id_data,
                  :hashed_in_person_data,
                  :hashed_check_data,
                  presence: true

        validates :hashed_id_data, uniqueness: { scope: :voting }
        validates :hashed_in_person_data, uniqueness: { scope: :voting }
        validates :hashed_check_data, uniqueness: { scope: :voting }
      end
    end
  end
end
