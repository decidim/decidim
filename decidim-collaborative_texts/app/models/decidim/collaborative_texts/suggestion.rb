# frozen_string_literal: true

module Decidim
  module CollaborativeTexts
    # The data store for a document in the Decidim::CollaborativeTexts component. It stores a
    # title, description and any other useful information to render a custom
    # document.
    class Suggestion < CollaborativeTexts::ApplicationRecord
      include Decidim::Traceable
      include Decidim::Authorable

      after_save :update_document_counters

      enum status: [:pending, :accepted, :rejected]
      belongs_to :document_version, class_name: "Decidim::CollaborativeTexts::Version", counter_cache: true, inverse_of: :suggestions
      has_one :document, class_name: "Decidim::CollaborativeTexts::Document", through: :document_version

      delegate :participatory_space, :organization, to: :document_version

      def self.log_presenter_class_for(_log)
        Decidim::CollaborativeTexts::AdminLog::SuggestionPresenter
      end

      def presenter
        @presenter ||= Decidim::CollaborativeTexts::SuggestionPresenter.new(self)
      end

      private

      def update_document_counters
        # Increment the counter cache for the document
        document.update_column(:suggestions_count, document.suggestions.count) # rubocop:disable Rails/SkipsModelValidations
      end
    end
  end
end
