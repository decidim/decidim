# frozen_string_literal: true

module Decidim
  module Accountability
    # The data store for a Result in the Decidim::Accountability component. It stores a
    # title, description and any other useful information to render a custom result.
    class Result < Accountability::ApplicationRecord
      include Decidim::Resourceable
      include Decidim::HasFeature
      include Decidim::HasScope
      include Decidim::HasCategory
      include Decidim::HasReference
      include Decidim::Comments::Commentable

      feature_manifest_name "accountability"

      has_many :children, foreign_key: "parent_id", class_name: "Decidim::Accountability::Result", inverse_of: :parent, dependent: :destroy
      belongs_to :parent, foreign_key: "parent_id", class_name: "Decidim::Accountability::Result", inverse_of: :children, optional: true, counter_cache: :children_count

      belongs_to :status, foreign_key: "decidim_accountability_status_id", class_name: "Decidim::Accountability::Status", inverse_of: :results, optional: true

      has_many :timeline_entries, -> { order(:entry_date) }, foreign_key: "decidim_accountability_result_id",
                                                             class_name: "Decidim::Accountability::TimelineEntry", inverse_of: :result, dependent: :destroy

      before_validation :remove_blank_values

      after_save :update_parent_progress, if: -> { parent_id.present? }

      def update_parent_progress
        return if parent.blank?

        parent.update_progress!
      end

      def update_progress!
        self.progress = children.average(:progress)
        save!
      end

      # Public: Overrides the `commentable?` Commentable concern method.
      def commentable?
        feature.settings.comments_enabled?
      end

      # Public: Overrides the `accepts_new_comments?` Commentable concern method.
      def accepts_new_comments?
        commentable? && !feature.current_settings.comments_blocked
      end

      # Public: Overrides the `comments_have_alignment?` Commentable concern method.
      def comments_have_alignment?
        true
      end

      # Public: Overrides the `comments_have_votes?` Commentable concern method.
      def comments_have_votes?
        true
      end

      private

      def remove_blank_values
        self.external_id = nil if external_id.blank?
      end
    end
  end
end
