# frozen_string_literal: true

module Decidim
  module Elections
    # The data store for tracking asynchronous Actions done in the Bulletin Board from the Decidim::Elections component.
    class Action < ApplicationRecord
      belongs_to :election, foreign_key: "decidim_elections_election_id", class_name: "Decidim::Elections::Election"

      enum status: [:pending, :accepted, :rejected]
      enum action: [:start_key_ceremony, :start_vote, :end_vote, :start_tally, :report_missing_trustee, :publish_results]
    end
  end
end
