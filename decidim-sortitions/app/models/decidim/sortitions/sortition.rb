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

      component_manifest_name "sortitions"

      belongs_to :decidim_proposals_component,
                 foreign_key: "decidim_proposals_component_id",
                 class_name: "Decidim::Component"

      belongs_to :cancelled_by_user,
                 foreign_key: "cancelled_by_user_id",
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

      def self.order_randomly(seed)
        transaction do
          connection.execute("SELECT setseed(#{connection.quote(seed)})")
          order(Arel.sql("RANDOM()")).load
        end
      end
    end
  end
end
