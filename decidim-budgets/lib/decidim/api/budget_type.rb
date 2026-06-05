# frozen_string_literal: true

module Decidim
  module Budgets
    class BudgetType < Decidim::Api::Types::BaseObject
      implements Decidim::Core::TimestampsInterface
      implements Decidim::Core::TraceableInterface
      implements Decidim::Core::TaxonomizableInterface

      description "A budget"

      field :description, Decidim::Core::TranslatedFieldType, "The description for this budget", null: false
      field :id, GraphQL::Types::ID, "The internal ID of this budget", null: false
      field :projects, [Decidim::Budgets::ProjectType, { null: true }], "The projects for this budget", null: false
      field :title, Decidim::Core::TranslatedFieldType, "The title for this budget", null: false
      field :total_budget, GraphQL::Types::Int, "The total budget", null: false, camelize: false,
                                                                    deprecation_reason: "Please use totalBudget instead. This field is deprecated since decidim 0.33.0, and will be removed in the upcoming versions" # rubocop:disable Layout/LineLength
      field :total_budget, GraphQL::Types::Int, "The total budget", null: false
      field :url, String, "The URL for this budget", null: false
      field :weight, GraphQL::Types::Int, "The weight for this budget", null: false

      def url
        Decidim::EngineRouter.main_proxy(object.component).budget_url(object)
      end

      def self.authorized?(object, context)
        return super if context[:trashable_deleted_resource] == object

        super && object.visible?
      end
    end
  end
end
