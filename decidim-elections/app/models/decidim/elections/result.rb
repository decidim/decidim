# frozen_string_literal: true

module Decidim
  module Elections
    # The data store for a Result in the Decidim::Elections component.
    class Result < ApplicationRecord
      include Traceable
      include Loggable

      belongs_to :answer, foreign_key: "decidim_elections_answer_id", class_name: "Decidim::Elections::Answer", inverse_of: :results
      belongs_to :polling_station, foreign_key: "decidim_votings_polling_station_id", class_name: "Decidim::Votings::PollingStation", optional: true

      validates :decidim_elections_answer_id, uniqueness: { scope: :polling_station }
      validates :decidim_votings_polling_station_id, uniqueness: { scope: :answer }
    end
  end
end
