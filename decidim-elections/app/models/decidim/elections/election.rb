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

      translatable_fields :title, :description

      component_manifest_name "elections"

      has_many :questions, foreign_key: "decidim_elections_election_id", class_name: "Decidim::Elections::Question", inverse_of: :election, dependent: :destroy
      has_many :elections_trustees, foreign_key: "decidim_elections_election_id", dependent: :destroy
      has_many :trustees, through: :elections_trustees

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

      # Public: Checks if the election questions are valid
      #
      # Returns a boolean.
      def valid_questions?
        questions.each do |question|
          return false unless question.valid_max_selection?
        end
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
