# frozen_string_literal: true

module Decidim
  module Elections
    # The data store for an Election in the Decidim::Elections component. It stores a
    # title, description and any other useful information to perform an election.
    class Election < ApplicationRecord
      include Decidim::Publicable
      include Decidim::Resourceable
      include Decidim::HasComponent
      include Decidim::TranslatableResource
      include Traceable
      include Loggable

      translatable_fields :title, :description, :subtitle

      component_manifest_name "elections"

      has_many :questions, foreign_key: "decidim_elections_election_id", class_name: "Decidim::Elections::Question", inverse_of: :election, dependent: :destroy

      def self.log_presenter_class_for(_log)
        Decidim::Elections::AdminLog::ElectionPresenter
      end

      # Public: Checks if the election started
      #
      # Returns a boolean.
      def started?
        start_time <= Time.current
      end

      # Public: Checks if the election finished
      #
      # Returns a boolean.
      def finished?
        end_time < Time.current
      end

      # Public: Checks if the election ongoing now
      #
      # Returns a boolean.
      def ongoing?
        started? && !finished?
      end

      # Public: Gets the voting period status of the election
      #
      # Returns one of these symbols: upcoming, ongoing or finished
      def voting_period_status
        if finished?
          :finished
        elsif started?
          :ongoing
        else
          :upcoming
        end
      end

      # Public: Overrides the Resourceable concern method to allow setting permissions at resource level
      def allow_resource_permissions?
        true
      end
    end
  end
end
