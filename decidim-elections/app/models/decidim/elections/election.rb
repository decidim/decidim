# frozen_string_literal: true

module Decidim
  module Elections
    # The data store for an Election in the Decidim::Elections component. It stores a
    # title, description and any other useful information to perform an election.
    class Election < ApplicationRecord
      include Decidim::HasAttachments
      include Decidim::HasAttachmentCollections
      include Decidim::Publicable
      include Decidim::Resourceable
      include Decidim::HasComponent
      include Decidim::TranslatableResource
      include Traceable
      include Loggable
      include Decidim::Forms::HasQuestionnaire
      include Decidim::FilterableResource

      translatable_fields :title, :description

      enum bb_status: [:created, :key_ceremony, :key_ceremony_ended, :vote, :vote_ended, :tally_started, :tally_ended, :results_published].index_with(&:to_s), _prefix: :bb

      component_manifest_name "elections"

      has_many :questions, foreign_key: "decidim_elections_election_id", class_name: "Decidim::Elections::Question", inverse_of: :election, dependent: :destroy
      has_many :elections_trustees, foreign_key: "decidim_elections_election_id", dependent: :destroy
      has_many :trustees, through: :elections_trustees
      has_many :votes, foreign_key: "decidim_elections_election_id", class_name: "Decidim::Elections::Vote", dependent: :restrict_with_exception
      has_many :actions, foreign_key: "decidim_elections_election_id", class_name: "Decidim::Elections::Action", dependent: :restrict_with_exception
      has_one :bb_closure, foreign_key: "decidim_elections_election_id", class_name: "Decidim::Elections::BulletinBoardClosure", dependent: :destroy

      scope :active, lambda {
        where("start_time <= ?", Time.current)
          .where("end_time >= ?", Time.current)
      }

      scope :upcoming, lambda {
        where("start_time > ?", Time.current)
          .where("end_time > ?", Time.current)
      }

      scope :finished, lambda {
        where("start_time < ?", Time.current)
          .where("end_time < ?", Time.current)
      }

      scope_search_multi :with_any_date, [:active, :upcoming, :finished]

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

      # Public: Checks if the election start_time is minimum some hours later than the present time
      #
      # Returns a boolean.
      def minimum_hours_before_start?
        start_time > (Time.zone.at(Decidim::Elections.setup_minimum_hours_before_start.hours.from_now))
      end

      # Public: Checks if the election start_time is maximum some hours before than the present time
      #
      # Returns a boolean.
      def maximum_hours_before_start?
        start_time < (Time.zone.at(Decidim::Elections.start_vote_maximum_hours_before_start.hours.from_now))
      end

      # Public: Checks if the number of answers are minimum 2 for each question
      #
      # Returns a boolean.
      def minimum_answers?
        # questions.any? && 
        questions.all? { |question| question.answers.size > 1 }
      end

      # Public: Checks if the election results are published and election finished
      #
      # Returns a boolean.
      def results_published?
        bb_results_published?
      end

      # Public: Checks if the election results are present
      #
      # Returns a boolean.
      def results?
        bb_tally_ended? || results_published?
      end

      # Public: Checks if the election questions are valid
      #
      # Returns a boolean.
      def valid_questions?
        # questions.any? && 
        questions.all?(&:valid_max_selection?)
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

      def trustee_action_required?
        bb_key_ceremony? || bb_tally_started?
      end

      # Public: Checks if the election has a blocked_at value
      #
      # Returns a boolean.
      def blocked?
        blocked_at.present?
      end

      # Public: Overrides the Resourceable concern method to allow setting permissions at resource level
      def allow_resource_permissions?
        true
      end

      # Create i18n ransackers for :title and :description.
      # Create the :search_text ransacker alias for searching from both of these.
      ransacker_i18n_multi :search_text, [:title, :description]

      def self.ransackable_scopes(_auth_object = nil)
        [:with_any_date]
      end
    end
  end
end
