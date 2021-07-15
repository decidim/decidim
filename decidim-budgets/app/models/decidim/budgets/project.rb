# frozen_string_literal: true

module Decidim
  module Budgets
    # The data store for a Project in the Decidim::Budgets component. It stores a
    # title, description and any other useful information to render a custom project.
    class Project < Budgets::ApplicationRecord
      include Decidim::Resourceable
      include Decidim::ScopableResource
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

      belongs_to :budget, foreign_key: "decidim_budgets_budget_id", class_name: "Decidim::Budgets::Budget", inverse_of: :projects
      has_one :component, through: :budget, foreign_key: "decidim_component_id", class_name: "Decidim::Component"
      has_many :line_items, class_name: "Decidim::Budgets::LineItem", foreign_key: "decidim_project_id", dependent: :destroy
      has_many :orders, through: :line_items, foreign_key: "decidim_project_id", class_name: "Decidim::Budgets::Order"

      delegate :organization, :participatory_space, to: :component

      scope :selected, -> { where.not(selected_at: nil) }
      scope :not_selected, -> { where(selected_at: nil) }

      searchable_fields(
        scope_id: :decidim_scope_id,
        participatory_space: { component: :participatory_space },
        A: :title,
        D: :description,
        datetime: :created_at
      )

      def self.ordered_ids(ids)
        # Make sure each ID in the matching text has a "," character as their
        # delimiter. Otherwise e.g. ID 2 would match ID "26" in the original
        # array. This is why we search for match ",2," instead to get the actual
        # position for ID 2.
        order(Arel.sql("position(concat(',', id::text, ',') in ',#{ids.join(",")},')"))
      end

      def self.log_presenter_class_for(_log)
        Decidim::Budgets::AdminLog::ProjectPresenter
      end

      def polymorphic_resource_path(url_params)
        ::Decidim::ResourceLocatorPresenter.new([budget, self]).path(url_params)
      end

      def polymorphic_resource_url(url_params)
        ::Decidim::ResourceLocatorPresenter.new([budget, self]).url(url_params)
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
        component.can_participate_in_space?(user)
      end

      # Public: Checks if the project has been selected or not.
      #
      # Returns Boolean.
      def selected?
        selected_at.present?
      end

      # Public: Returns the attachment context for this record.
      def attachment_context
        :admin
      end
    end
  end
end
