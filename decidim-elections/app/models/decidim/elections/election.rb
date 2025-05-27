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
      has_one :questionnaire, as: :questionnaire_for, class_name: "Decidim::Elections::Questionnaire", dependent: :destroy

      component_manifest_name "elections"

      translatable_fields :title, :description

      validates :title, presence: true

      enum results_availability: RESULTS_AVAILABILITY_OPTIONS.index_with(&:to_s), _prefix: "results"

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

      def internal_census?
        internal_census
      end

      def external_census?
        !internal_census?
      end

      def verification_filters
        verification_types.presence || []
      end

      def census_status
        @census_status ||= CsvCensus::Status.new(self)
      end

      # Public: Checks if the census status for the election is "ready".
      #
      # Returns a boolean indicating if the census status equals "ready" or if it's an internal census selection and there are not verification types or voters.
      def census_ready?
        census_status&.name == "ready" || (internal_census? && verification_types.empty?) || (internal_census? && voters.empty?)
      end
    end
  end
end
