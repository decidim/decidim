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
      include Decidim::FilterableResource
      include ActionView::Helpers::NumberHelper

      RESULTS_AVAILABILITY_OPTIONS = %w(real_time per_question after_end).freeze

      has_many :voters, class_name: "Decidim::Elections::Voter", inverse_of: :election, dependent: :destroy
      has_many :questions, class_name: "Decidim::Elections::Question", inverse_of: :election, dependent: :destroy

      component_manifest_name "elections"

      translatable_fields :title, :description

      validates :title, presence: true

      enum :results_availability, RESULTS_AVAILABILITY_OPTIONS.index_with(&:to_s), prefix: "results"

      scope :scheduled, -> { published.where(start_at: Time.current..).or(published.where(start_at: nil, published_results_at: nil, end_at: Time.current..)) }
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

      def real_time?
        results_availability == "real_time"
      end

      def after_end?
        results_availability == "after_end"
      end

      def per_question?
        results_availability == "per_question"
      end

      def auto_start?
        start_at.present?
      end

      def manual_start?
        !auto_start?
      end

      def scheduled?
        published? && !ongoing? && !finished? && !published_results?
      end

      def started?
        start_at.present? && start_at <= Time.current
      end

      def ongoing?
        started? && !finished?
      end

      def finished?
        # If end_at is present and in the past, the election is finished no matter what type of voting
        @finished ||= if end_at.present? && end_at <= Time.current
                        true
                      elsif per_question?
                        # Per question elections are considered finished if all questions have published results
                        questions.all?(&:published_results?)
                      else
                        false
                      end
      end

      def published_results?
        results_at.present?
      end

      # Date of results publication vary depending on the results_availability
      # If results_availability is "per_question", the results are published when the first question
      # has its results published.
      # If results_availability is "real_time", the results are published as soon as the election has started.
      # If "after_end", publication is manual
      def results_at
        return nil unless published?
        return nil unless started?
        return questions.published_results.first&.published_results_at if per_question?
        return start_at if real_time?

        published_results_at
      end

      def census
        @census ||= Decidim::Elections.census_registry.find(census_manifest)
      end

      # syntax sugar to access the census manifest
      def census_ready?
        return false if census.nil?

        census.ready?(self)
      end

      # if per question, only the enabled questions are returned
      # if not, all questions are returned
      def available_questions
        return questions.enabled.unpublished_results if per_question?

        questions
      end

      def status
        return @status if defined?(@status)

        @status =
          if !published?
            :unpublished
          elsif ongoing?
            :ongoing
          elsif finished?
            :finished
          else
            :scheduled
          end
      end

      # Returns the questions that are available for results.
      def result_published_questions
        return questions.published_results if per_question?
        return available_questions if published_results?

        []
      end

      scope_search_multi :with_any_state, [:ongoing, :finished, :scheduled]

      # Create i18n ransackers for :title and :description.
      # Create the :search_text ransacker alias for searching from both of these.
      ransacker_i18n_multi :search_text, [:title, :description]

      def self.ransackable_scopes(_auth_object = nil)
        [:with_any_state]
      end

      def self.ransackable_associations(_auth_object = nil)
        %w(questions response_options)
      end

      def self.ransackable_attributes(_auth_object = nil)
        %w(search_text title description)
      end
    end
  end
end
