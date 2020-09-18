# frozen_string_literal: true

module Decidim
  module Elections
    # The data store for an Election-Trustee relation in the Decidim::Elections component.
    class ElectionsTrustee < ApplicationRecord
      belongs_to :election, foreign_key: "decidim_elections_election_id", class_name: "Decidim::Elections::Election"
      belongs_to :trustee, foreign_key: "decidim_elections_trustee_id", class_name: "Decidim::Elections::Trustee"
    end
  end
end
