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
      validate :either_president_or_manager

      delegate :name, :nickname, :email, to: :user
      alias participatory_space voting

      # Allow ransacker to search by presided/managed polling station title
      %w(managed_station presided_station).each do |table|
        ransacker "#{table}_title".to_sym do
          Arel::Nodes::InfixOperation.new("->>", Arel.sql("#{table}.title"), Arel::Nodes.build_quoted(I18n.locale.to_s))
        end
      end

      # Allow ransacker to search by user attributes
      [:name, :email, :nickname].each do |field|
        ransacker field do
          Arel.sql("decidim_users.#{field}")
        end
      end

      def self.polling_officer?(user)
        exists?(user:)
      end

      def self.for(user)
        where(user:)
      end

      def role
        return :president if presided_polling_station.present?
        return :manager if managed_polling_station.present?

        :unassigned
      end

      def polling_station
        presided_polling_station || managed_polling_station
      end

      def self.log_presenter_class_for(_log)
        Decidim::Votings::AdminLog::PollingOfficerPresenter
      end

      private

      # Private: check if the voting and the user have the same organization
      def user_and_voting_same_organization
        return if voting.nil? || user.nil?

        errors.add(:voting, :different_organization) unless user.organization == voting.organization
      end

      # Private: check if the voting and the user have the same organization
      def either_president_or_manager
        return if presided_polling_station.nil? || managed_polling_station.nil?

        errors.add(:presided_polling_station, :president_and_manager)
      end
    end
  end
end
