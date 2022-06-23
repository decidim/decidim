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
      include Decidim::Comments::CommentableWithComponent
      include Decidim::Traceable
      include Decidim::Loggable
      include Decidim::Randomable
      include Decidim::Searchable
      include Decidim::TranslatableResource
      include Decidim::FilterableResource

      translatable_fields :title, :description

      belongs_to :budget, foreign_key: "decidim_budgets_budget_id", class_name: "Decidim::Budgets::Budget", inverse_of: :projects
      has_one :component, through: :budget, foreign_key: "decidim_component_id", class_name: "Decidim::Component"
      has_many :line_items, class_name: "Decidim::Budgets::LineItem", foreign_key: "decidim_project_id", dependent: :destroy
      has_many :orders, through: :line_items, foreign_key: "decidim_project_id", class_name: "Decidim::Budgets::Order"

      delegate :organization, :participatory_space, :can_participate_in_space?, to: :component

      alias can_participate? can_participate_in_space?

      scope :selected, -> { where.not(selected_at: nil) }
      scope :not_selected, -> { where(selected_at: nil) }

      geocoded_by :address

      scope_search_multi :with_any_status, [:selected, :not_selected]

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
        concat_ids = connection.quote(",#{ids.join(",")},")
        order(Arel.sql("position(concat(',', id::text, ',') in #{concat_ids})"))
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

      ransacker :id_string do
        Arel.sql(%{cast("decidim_budgets_projects"."id" as text)})
      end

      # Create i18n ransackers for :title and :description.
      # Create the :search_text ransacker alias for searching from both of these.
      ransacker_i18n_multi :search_text, [:title, :description]

      ransacker :selected do
        Arel.sql(%{("decidim_budgets_projects"."selected_at")::text})
      end

      ransacker :confirmed_orders_count do
        query = <<-SQL.squish
        (
            SELECT COUNT(decidim_budgets_line_items.decidim_order_id)
            FROM decidim_budgets_line_items
            LEFT JOIN decidim_budgets_orders ON decidim_budgets_orders.id = decidim_budgets_line_items.decidim_order_id
            WHERE decidim_budgets_orders.checked_out_at IS NOT NULL
            AND decidim_budgets_projects.id = decidim_budgets_line_items.decidim_project_id
        )
        SQL
        Arel.sql(query)
      end

      def self.ransackable_scopes(_auth_object = nil)
        [:with_any_status, :with_any_scope, :with_any_category]
      end
    end
  end
end
