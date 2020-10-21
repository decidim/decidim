# frozen_string_literal: true

module Decidim
  module Sortitions
    # Model that encapsulates the parameters of a sortion
    class Sortition < ApplicationRecord
      include Decidim::Resourceable
      include Decidim::HasCategory
      include Decidim::Authorable
      include Decidim::HasComponent
      include Decidim::HasReference
      include Decidim::Traceable
      include Decidim::Loggable
      include Decidim::Comments::Commentable
      include Decidim::Randomable
      include Decidim::TranslatableResource

      component_manifest_name "sortitions"

      translatable_fields :title, :witnesses, :additional_info, :cancel_reason

      belongs_to :decidim_proposals_component,
                 class_name: "Decidim::Component"

      belongs_to :cancelled_by_user,
                 class_name: "Decidim::User",
                 optional: true

      scope :categorized_as, lambda { |category_id|
        includes(:categorization)
          .where("decidim_categorizations.decidim_category_id" => category_id)
      }

      scope :active, -> { where(cancelled_on: nil) }
      scope :cancelled, -> { where.not(cancelled_on: nil) }

      def self.log_presenter_class_for(_log)
        Decidim::Sortitions::AdminLog::SortitionPresenter
      end

      def proposals
        Decidim::Proposals::Proposal.where(id: selected_proposals)
      end

      def similar_count
        Sortition.where(component: component)
                 .where(decidim_proposals_component: decidim_proposals_component)
                 .categorized_as(category&.id)
                 .where(target_items: target_items)
                 .count
      end

      def seed
        request_timestamp.to_i * dice
      end

      def cancelled?
        cancelled_on.present?
      end

      # Public: Overrides the `commentable?` Commentable concern method.
      def commentable?
        component.settings.comments_enabled?
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

      # Public: Whether the object can have new comments or not.
      def user_allowed_to_comment?(user)
        can_participate_in_space?(user)
      end
    end
  end
end
