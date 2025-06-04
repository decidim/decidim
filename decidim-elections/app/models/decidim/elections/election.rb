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
    end
  end
end
