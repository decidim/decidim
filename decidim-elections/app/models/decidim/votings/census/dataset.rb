# frozen_string_literal: true

module Decidim
  module Votings
    module Census
      class Dataset < ApplicationRecord
        include Traceable
        include Loggable

        # The data store for a whole Census for a voting.
        belongs_to :voting, foreign_key: :decidim_votings_voting_id,
                            class_name: "Decidim::Votings::Voting"
        has_many :data,
                 foreign_key: "decidim_votings_census_dataset_id",
                 class_name: "Decidim::Votings::Census::Datum",
                 dependent: :destroy

        has_one_attached :access_codes_file

        delegate :organization, to: :voting

        enum status: [:init_data, :creating_data, :data_created, :generating_codes, :codes_generated, :exporting_codes, :freeze]

        validates :filename, presence: true

        alias participatory_space voting

        def self.log_presenter_class_for(_log)
          Decidim::Votings::Census::AdminLog::DatasetPresenter
        end
      end
    end
  end
end
