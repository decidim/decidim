# frozen_string_literal: true

module Decidim
  module Votings
    class PollingOfficer < ApplicationRecord
      include Traceable
      include Loggable

      belongs_to :user, foreign_key: "decidim_user_id", class_name: "Decidim::User"
      belongs_to :voting, foreign_key: "decidim_votings_voting_id", class_name: "Decidim::Votings::Voting", inverse_of: :polling_officers
      belongs_to :managed_polling_station,
                 class_name: "Decidim::Votings::PollingStation",
                 inverse_of: :polling_station_managers,
                 optional: true
      belongs_to :presided_polling_station,
                 class_name: "Decidim::Votings::PollingStation",
                 inverse_of: :polling_station_president,
                 optional: true

      validates :user, uniqueness: { scope: :voting }
      validate :user_and_voting_same_organization

      delegate :name, :nickname, :email, to: :user

      private

      # Private: check if the voting and the user have the same organization
      def user_and_voting_same_organization
        return if voting.nil? || user.nil?

        errors.add(:voting, :different_organization) unless user.organization == voting.organization
      end
    end
  end
end
