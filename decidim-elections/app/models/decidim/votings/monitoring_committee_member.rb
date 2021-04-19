# frozen_string_literal: true

module Decidim
  module Votings
    class MonitoringCommitteeMember < ApplicationRecord
      include Traceable
      include Loggable

      belongs_to :user, foreign_key: "decidim_user_id", class_name: "Decidim::User", optional: true
      belongs_to :voting, foreign_key: "decidim_votings_voting_id", class_name: "Decidim::Votings::Voting", inverse_of: :monitoring_committee_members

      validate :user_and_voting_same_organization

      private

      # Private: check if the voting and the user have the same organization
      def user_and_voting_same_organization
        return if !voting || !user

        errors.add(:voting, :invalid) unless user.organization == voting.organization
      end
    end
  end
end
