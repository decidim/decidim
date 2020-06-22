# frozen_string_literal: true

module Decidim
  module Budgets
    # The data store for a Project in the Decidim::Budgets component. It stores a
    # title, description and any other useful information to render a custom project.
    class Project < Budgets::ApplicationRecord
      include Decidim::Resourceable
      include Decidim::HasComponent
      include Decidim::ScopableComponent
      include Decidim::HasCategory
      include Decidim::HasAttachments
      include Decidim::HasAttachmentCollections
      include Decidim::HasReference
      include Decidim::Followable
      include Decidim::Comments::Commentable
      include Decidim::Traceable
      include Decidim::Loggable
      include Decidim::Randomable
      include Decidim::Searchable
      include Decidim::TranslatableResource

      translatable_fields :title, :description

      component_manifest_name "budgets"
      has_many :line_items, class_name: "Decidim::Budgets::LineItem", foreign_key: "decidim_project_id", dependent: :destroy
      has_many :orders, through: :line_items, foreign_key: "decidim_project_id", class_name: "Decidim::Budgets::Order"

      searchable_fields(
        scope_id: :decidim_scope_id,
        participatory_space: { component: :participatory_space },
        A: :title,
        D: :description,
        datetime: :created_at
      )

      def self.ordered_ids(ids)
        order(Arel.sql("position(id::text in '#{ids.join(",")}')"))
      end

      def self.log_presenter_class_for(_log)
        Decidim::Budgets::AdminLog::ProjectPresenter
      end

      # Public: Overrides the `commentable?` Commentable concern method.
      def commentable?
        component.settings.comments_enabled?
      end

      # Public: Overrides the `accepts_new_comments?` Commentable concern method.
      def accepts_new_comments?
        commentable? && !component.current_settings.comments_blocked
      end

      # Public: Overrides the `comments_have_votes?` Commentable concern method.
      def comments_have_votes?
        true
      end

      # Public: Overrides the `users_to_notify_on_comment_created` Commentable concern method.
      def users_to_notify_on_comment_created
        followers
      end

      # Public: Returns the number of times an specific project have been checked out.
      def confirmed_orders_count
        orders.finished.count
      end

      # Public: Overrides the `allow_resource_permissions?` Resourceable concern method.
      def allow_resource_permissions?
        component.settings.resources_permissions_enabled
      end

      # Public: Whether the object can have new comments or not.
      def user_allowed_to_comment?(user)
        can_participate_in_space?(user)
      end
    end
  end
end
