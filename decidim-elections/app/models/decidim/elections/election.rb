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

      delegate :scheduled?, :ongoing?, :vote_ended?, :ready_to_publish_results?, :results_published?, :current_status, :localized_status, to: :status

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

      def status
        @status ||= Decidim::Elections::ElectionStatus.new(self)
      end

      def results_publishable_for?(question)
        case results_availability
        when "per_question"
          publishable_per_question?(question)
        when "after_end"
          ready_to_publish_results?
        else
          false
        end
      end

      def publishable_per_question?(question)
        return false unless questions.include?(question)

        index = questions.index(question)
        return true if index.zero?

        previous_question = questions[index - 1]
        previous_question.published_results_at.present?
      end
    end
  end
end
