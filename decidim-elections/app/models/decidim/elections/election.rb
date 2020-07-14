# frozen_string_literal: true

module Decidim
  module Elections
    # The data store for an Election in the Decidim::Elections component. It stores a
    # title, description and any other useful information to perform an election.
    class Election < ApplicationRecord
      include Decidim::Publicable
      include Decidim::Resourceable
      include Decidim::HasComponent
      include Traceable
      include Loggable

      component_manifest_name "elections"

      has_many :questions, foreign_key: "decidim_elections_election_id", class_name: "Decidim::Elections::Question", inverse_of: :election, dependent: :destroy

      def self.log_presenter_class_for(_log)
        Decidim::Elections::AdminLog::ElectionPresenter
      end

      def started?
        start_time <= Time.current
      end

      def finished?
        end_time < Time.current
      end

      def ongoing?
        started? && !finished?
      end

      def voting_period_status
        if finished?
          :finished
        elsif started?
          :ongoing
        else
          :upcoming
        end
      end

      def allow_resource_permissions?
        true
      end
    end
  end
end
