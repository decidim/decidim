# frozen_string_literal: true

module Decidim
  module Sortitions
    # Model that encapsulates the parameters of a sortition
    class Sortition < ApplicationRecord
      include Decidim::Resourceable
      include Decidim::HasCategory
      include Decidim::Taxonomizable
      include Decidim::Authorable
      include Decidim::HasComponent
      include Decidim::HasReference
      include Decidim::Traceable
      include Decidim::Loggable
      include Decidim::Comments::CommentableWithComponent
      include Decidim::Randomable
      include Decidim::TranslatableResource
      include Decidim::FilterableResource

      component_manifest_name "sortitions"

      translatable_fields :title, :witnesses, :additional_info, :cancel_reason

      belongs_to :decidim_proposals_component,
                 class_name: "Decidim::Component"

      belongs_to :cancelled_by_user,
                 class_name: "Decidim::User",
                 optional: true

      scope :active, -> { where(cancelled_on: nil) }
      scope :cancelled, -> { where.not(cancelled_on: nil) }

      scope_search_multi :with_any_state, [:active, :cancelled]

      def self.log_presenter_class_for(_log)
        Decidim::Sortitions::AdminLog::SortitionPresenter
      end

      def presenter
        Decidim::Sortitions::SortitionPresenter.new(self)
      end

      def proposals
        Decidim::Proposals::Proposal.where(id: selected_proposals)
      end

      def similar_count
        Sortition.where(component:)
                 .where(decidim_proposals_component:)
                 .with_taxonomies(*taxonomies.map(&:id))
                 .where(target_items:)
                 .count
      end

      def seed
        request_timestamp.to_i * dice
      end

      def cancelled?
        cancelled_on.present?
      end

      # Public: Overrides the `accepts_new_comments?` Commentable concern method.
      def accepts_new_comments?
        commentable?
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

      # Create i18n ransackers for :title, :additional_info and :witnesses.
      # Create the :search_text ransacker alias for searching from all of these.
      ransacker_i18n_multi :search_text, [:title, :additional_info, :witnesses]

      def self.ransackable_scopes(_auth_object = nil)
        [:with_any_state, :with_any_taxonomies]
      end

      def self.ransackable_attributes(_auth_object = nil)
        %w(additional_info cancel_reason cancelled_by_user_id cancelled_on candidate_proposals comments_count created_at decidim_author_id
           decidim_author_type decidim_component_id decidim_proposals_component_id dice id reference request_timestamp search_text selected_proposals
           target_items title updated_at witnesses)
      end

      def self.ransackable_associations(_auth_object = nil)
        %w(author cancelled_by_user taxonomies comment_threads comments component decidim_proposals_component resource_links_from
           resource_links_to resource_permission versions)
      end
    end
  end
end
