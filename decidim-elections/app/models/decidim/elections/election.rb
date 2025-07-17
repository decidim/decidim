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
      has_many :votes,
               foreign_key: "decidim_election_id",
               class_name: "Decidim::Elections::Vote",
               through: :questions,
               dependent: :restrict_with_error

      component_manifest_name "elections"

      translatable_fields :title, :description

      validates :title, presence: true

      enum :results_availability, RESULTS_AVAILABILITY_OPTIONS.index_with(&:to_s), prefix: "results"

      scope :scheduled, -> { published.where(start_at: Time.current..).or(published.where(start_at: nil, published_results_at: nil, end_at: Time.current..)) }
      scope :ongoing, -> { published.where(start_at: ..Time.current, end_at: Time.current..) }
      scope :finished, -> { published.where(end_at: ..Time.current) }
      scope :results_published, -> { published.where.not(published_results_at: nil).or(published.finished.where(results_availability: %w(real_time per_question))) }

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

      def update_votes_count!
        update(votes_count: votes.count)
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
                           elsif per_question? && started?
                             # Per question elections are considered finished if all questions have published results
                             questions.all?(&:published_results?)
                           else
                             false
                           end
      end

      def census
        @census ||= Decidim::Elections.census_registry.find(census_manifest)
      end

      # syntax sugar to access the census manifest
      def census_ready?
        return false if census.nil?

        census.ready?(self)
      end

      def ready_to_publish_results?
        return false unless published?
        return false if results_published?
        return false if questions.empty?

        return vote_finished? unless per_question?

        # If per_question, we can publish when there is at least one question enabled
        questions.unpublished_results.enabled.any?
      end

      def per_question?
        results_availability == "per_question"
      end

      def per_question_waiting?
        per_question? && !finished? && questions.unpublished_results.disabled.any?
      end

      # if per question, only the enabled questions are returned
      # if not, all questions are returned
      def available_questions
        return questions.enabled if per_question?

        questions
      end

      def status
        return :unpublished unless published?
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
          vote_finished? && questions.enabled.any? && questions.enabled.any?(&:published_results_at)
        when "after_end"
          published_results_at.present?
        else
          false
        end
      end

      # Returns the questions that are available for results.
      def result_published_questions
        return available_questions if results_published?

        return questions.published_results if results_availability == "per_question"

        []
      end

      def to_json(admin: false)
        {
          id: id,
          ongoing: ongoing?,
          status: status,
          start_date: start_at&.iso8601,
          end_date: end_at.iso8601,
          title: translated_attribute(title),
          description: translated_attribute(description),
          questions: available_questions.map do |question|
            {
              id: question.id,
              body: translated_attribute(question.body),
              position: question.position,
              response_options: question.response_options.map do |option|
                {
                  id: option.id,
                  body: translated_attribute(option.body)
                }.tap do |hash|
                  next unless admin || result_published_questions.include?(question)

                  hash[:votes_count] = option.votes_count
                  hash[:votes_count_text] = I18n.t("votes_count", scope: "decidim.elections.elections.show", count: option.votes_count)
                  hash[:votes_percent_text] = number_to_percentage(option.votes_percent, precision: 1)
                  hash[:votes_percent] = option.votes_percent
                end
              end
            }
          end
        }
      end

      scope_search_multi :with_any_state, [:ongoing, :finished, :results_published, :scheduled]

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
