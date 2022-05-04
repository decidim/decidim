# frozen_string_literal: true

module Decidim
  module Accountability
    # The data store for a Result in the Decidim::Accountability component. It stores a
    # title, description and any other useful information to render a custom result.
    class Result < Accountability::ApplicationRecord
      include Decidim::Resourceable
      include Decidim::HasAttachments
      include Decidim::HasAttachmentCollections
      include Decidim::HasComponent
      include Decidim::ScopableResource
      include Decidim::HasCategory
      include Decidim::HasReference
      include Decidim::Comments::CommentableWithComponent
      include Decidim::Traceable
      include Decidim::Loggable
      include Decidim::DownloadYourData
      include Decidim::Randomable
      include Decidim::Searchable
      include Decidim::TranslatableResource
      include Decidim::FilterableResource

      component_manifest_name "accountability"

      translatable_fields :title, :description

      has_many :children, foreign_key: "parent_id", class_name: "Decidim::Accountability::Result", inverse_of: :parent, dependent: :destroy
      belongs_to :parent, class_name: "Decidim::Accountability::Result", inverse_of: :children, optional: true, counter_cache: :children_count

      belongs_to :status, foreign_key: "decidim_accountability_status_id", class_name: "Decidim::Accountability::Status", inverse_of: :results, optional: true

      has_many :timeline_entries, -> { order(:entry_date) }, foreign_key: "decidim_accountability_result_id",
                                                             class_name: "Decidim::Accountability::TimelineEntry", inverse_of: :result, dependent: :destroy

      scope :order_by_most_recent, -> { order(created_at: :desc) }

      after_save :update_parent_progress, if: -> { parent_id.present? }

      searchable_fields(
        scope_id: :decidim_scope_id,
        participatory_space: { component: :participatory_space },
        A: :title,
        D: :description,
        datetime: :start_date
      )

      def self.log_presenter_class_for(_log)
        Decidim::Accountability::AdminLog::ResultPresenter
      end

      def update_parent_progress
        return if parent.blank?

        parent.update_progress!
      end

      # Public: There are two ways to update parent's progress:
      #   - using weights, in which case each progress is multiplied by the weigth and them summed
      #   - not using weights, and using the average of progress of each children
      def update_progress!
        self.progress = if children_use_weighted_progress?
                          children.sum { |result| (result.progress.presence || 0) * (result.weight.presence || 1) }
                        else
                          children.average(:progress)
                        end
        save!
      end

      # Public: Overrides the `comments_have_alignment?` Commentable concern method.
      def comments_have_alignment?
        true
      end

      # Public: Overrides the `comments_have_votes?` Commentable concern method.
      def comments_have_votes?
        true
      end

      # Public: Overrides the `allow_resource_permissions?` Resourceable concern method.
      def allow_resource_permissions?
        true
      end

      def self.ransackable_scopes(_auth_object = nil)
        [:with_category, :with_scope]
      end

      ransacker :id_string do
        Arel.sql(%{cast("decidim_accountability_results"."id" as text)})
      end

      # Create i18n ransackers for :title and :description.
      # Create the :search_text ransacker alias for searching from both of these.
      ransacker_i18n_multi :search_text, [:title, :description]

      private

      # Private: When a row uses weight 1 and there's more than one, weight shouldn't be considered
      # Handle special case when all children weight are nil
      def children_use_weighted_progress?
        return false if children.pluck(:weight).all?(&:nil?)

        children.length == 1 || children.pluck(:weight).none? { |weight| weight&.to_d == 1.0.to_d }
      end
    end
  end
end
