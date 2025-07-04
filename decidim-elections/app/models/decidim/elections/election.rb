# frozen_string_literal: true

module Decidim
  module Elections
    # The data store for a document in the Decidim::Elections component. It stores a
    # title, description and any other useful information to render a custom
    # document.
    class Election < Elections::ApplicationRecord
      include Decidim::Resourceable
      include Decidim::SoftDeletable
      include Decidim::HasComponent
      include Decidim::HasAttachments
      include Decidim::Publicable
      include Decidim::Traceable
      include Decidim::TranslatableResource
      include Decidim::TranslatableAttributes
      include Decidim::Loggable
      include Decidim::Searchable
      include Decidim::Reportable

      RESULTS_AVAILABILITY_OPTIONS = %w(real_time per_question after_end).freeze

      has_many :voters, class_name: "Decidim::Elections::Voter", inverse_of: :election, dependent: :destroy
      has_many :questions, class_name: "Decidim::Elections::Question", inverse_of: :election, dependent: :destroy

      component_manifest_name "elections"

      translatable_fields :title, :description

      validates :title, presence: true

      enum :results_availability, RESULTS_AVAILABILITY_OPTIONS.index_with(&:to_s), prefix: "results"

      scope :upcoming, -> { published.where(start_at: Time.current..) }
      scope :ongoing, -> { published.where(start_at: ..Time.current, end_at: Time.current..) }
      scope :finished, -> { published.where(end_at: ..Time.current) }

      searchable_fields(
        A: :title,
        D: :description,
        participatory_space: { component: :participatory_space }
      )

      def presenter
        Decidim::Elections::ElectionPresenter.new(self)
      end

      def self.log_presenter_class_for(_log)
        Decidim::Elections::AdminLog::ElectionPresenter
      end

      def auto_start?
        start_at.present?
      end

      def manual_start?
        !auto_start?
      end

      def scheduled?
        published? && !ongoing? && !vote_finished? && !results_published?
      end

      def started?
        start_at.present? && start_at <= Time.current
      end

      def ongoing?
        started? && !vote_finished?
      end

      def finished?
        end_at.present? && end_at <= Time.current
      end

      def vote_finished?
        # If end_at is present and in the past, the election is finished no matter what type of voting
        @vote_finished ||= if end_at.present? && end_at <= Time.current
                             true
                             # Per question elections are considered finished if all questions have published results
                             # as long as there is at least one question enabled
                           elsif per_question? && questions.enabled.any?
                             questions.all?(&:published_results?)
                           else
                             false
                           end
      end

      def verification_filters
        verification_types.presence || []
      end

      def census
        @census ||= Decidim::Elections.census_registry.find(census_manifest)
      end

      def census_status
        @census_status ||= CsvCensus::Status.new(self)
      end

      # syntax sugar to access the census manifest
      def census_ready?
        return false if census.nil?

        census.ready?(self)
      end

      def ready_to_publish_results?
        return false unless published? || results_published?

        return vote_finished? unless per_question?

        return false if questions.empty?

        # If per_question, we can publish when there is at least one question enabled
        questions.unpublished_results.any?(&:voting_enabled?)
      end

      def per_question?
        results_availability == "per_question"
      end

      def per_question_waiting?
        per_question? && !finished? && questions.unpublished_results.none?(&:voting_enabled?)
      end

      def current_status
        return :ongoing if ongoing?
        return :results_published if results_published?
        return :finished if vote_finished?

        :scheduled
      end

      def results_published?
        case results_availability
        when "real_time"
          ongoing? || vote_finished? || published_results_at.present?
        when "per_question"
          questions.enabled.any? && questions.enabled.all?(&:published_results_at)
        when "after_end"
          published_results_at.present?
        else
          false
        end
      end
    end
  end
end
