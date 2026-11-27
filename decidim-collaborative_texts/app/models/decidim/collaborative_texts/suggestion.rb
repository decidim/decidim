# frozen_string_literal: true

module Decidim
  module CollaborativeTexts
    # The data store for a document in the Decidim::CollaborativeTexts component. It stores a
    # title, description and any other useful information to render a custom
    # document.
    class Suggestion < CollaborativeTexts::ApplicationRecord
      include Decidim::Traceable
      include Decidim::Authorable
      include Decidim::Resourceable
      include Decidim::Comments::Commentable

      after_save :update_document_counters

      enum :status, [:pending, :accepted, :rejected]
      belongs_to :document_version, class_name: "Decidim::CollaborativeTexts::Version", counter_cache: true, inverse_of: :suggestions
      has_one :document, class_name: "Decidim::CollaborativeTexts::Document", through: :document_version

      delegate :component, to: :document_version
      delegate :participatory_space, :organization, to: :document_version
      delegate :can_participate?, to: :document

      def self.log_presenter_class_for(_log)
        Decidim::CollaborativeTexts::AdminLog::SuggestionPresenter
      end

      def presenter
        @presenter ||= Decidim::CollaborativeTexts::SuggestionPresenter.new(self)
      end

      # Public: Overrides the `commentable?` Commentable concern method.
      def commentable?
        return false unless document&.published?

        component&.published? && participatory_space&.published?
      end

      # Public: Overrides the `accepts_new_comments?` Commentable concern method.
      def accepts_new_comments?
        commentable?
      end

      # Public: Overrides the `user_allowed_to_comment?` Commentable concern method.
      def user_allowed_to_comment?(user)
        return false unless user

        participatory_space.can_participate?(user)
      end

      # Public: Overrides the `users_to_notify_on_comment_created` Commentable concern method.
      def users_to_notify_on_comment_created
        return Decidim::User.none unless author.is_a?(Decidim::User)

        Decidim::User.where(id: author.id)
      end

      private

      def update_document_counters
        # Increment the counter cache for the document
        document.update_column(:suggestions_count, document.suggestions.count) # rubocop:disable Rails/SkipsModelValidations
      end
    end
  end
end
