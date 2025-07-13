# frozen_string_literal: true

module Decidim
  module Budgets
    class ProjectType < Decidim::Api::Types::BaseObject
      implements Decidim::Core::TimestampsInterface
      implements Decidim::Core::TaxonomizableInterface
      implements Decidim::Core::AttachableInterface
      implements Decidim::Comments::CommentableInterface
      implements Decidim::Core::AttachableCollectionInterface
      implements Decidim::Core::FollowableInterface
      implements Decidim::Core::LocalizableInterface
      implements Decidim::Core::TimestampsInterface
      implements Decidim::Core::ReferableInterface
      implements Decidim::Core::TraceableInterface

      description "A project"

      field :budget_amount, GraphQL::Types::Int, "The budget amount for this project", null: true, camelize: false
      field :budget_url, String, "The URL for the budget", null: false
      field :confirmed_votes, Integer, "The number of confirmed votes this project has received", null: true
      field :description, Decidim::Core::TranslatedFieldType, "The description for this project", null: true
      field :id, GraphQL::Types::ID, "The internal ID for this project", null: false
      field :related_proposals, [Decidim::Proposals::ProposalType, { null: true }], "The related proposals", null: true
      field :selected, GraphQL::Types::Boolean, "Whether this proposal is selected or not", method: :selected?, null: true
      field :selected_at, Decidim::Core::DateTimeType, "The date when the project was selected", null: true
      field :title, Decidim::Core::TranslatedFieldType, "The title for this project", null: true
      field :url, String, "The URL for this project", null: false

      def confirmed_votes
        return unless object.component.current_settings.show_votes?

        object.confirmed_orders_count
      end

      def related_proposals
        object.linked_resources(:proposals, "included_proposals")
      end

      def url
        object.resource_locator.url
      end

      def budget_url
        Decidim::EngineRouter.main_proxy(object.component).budget_url(object.budget)
      end

      def self.authorized?(object, context)
        context[:project] = object

        chain = [
          allowed_to?(:read, :project, object, context),
          object.visible?
        ].all?

        super && chain
      rescue Decidim::PermissionAction::PermissionNotSetError
        false
      end
    end
  end
end
