# frozen_string_literal: true

module Decidim
  module Elections
    # The data store for an Answer in the Decidim::Elections component. It stores a
    # title, description and related resources and attachments.
    class Action < ApplicationRecord
      belongs_to :election, foreign_key: "decidim_elections_election_id", class_name: "Decidim::Elections::Election"

      enum status: [:pending, :accepted, :rejected]
      enum action: [:start_key_ceremony, :start_vote, :end_vote, :start_tally]
    end
  end
end
