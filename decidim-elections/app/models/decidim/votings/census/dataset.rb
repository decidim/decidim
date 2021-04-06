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

        enum status: [:init_data, :creating_data, :data_created, :generating_codes, :codes_generated, :freeze]

        validates :file, presence: true

        def self.log_presenter_class_for(_log)
          Decidim::Votings::Census::AdminLog::DatasetPresenter
        end
      end
    end
  end
end
