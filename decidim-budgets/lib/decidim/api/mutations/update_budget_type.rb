# frozen_string_literal: true

module Decidim
  module Budgets
    class UpdateBudgetType < Decidim::Api::Types::BaseMutation
      description "Updates a budget"
      type Decidim::Budgets::BudgetType

      required_scopes "api:read", "admin:read", "admin:write"

      argument :attributes, BudgetAttributes, description: "Input attributes to update a budget", required: true

      def resolve(attributes:)
        params = extract_from(attributes)

        form = form(Admin::BudgetForm).from_params(params)

        Admin::UpdateBudget.call(form, object) do
          on(:ok, resource) do
            return resource.reload
          end

          on(:invalid) do
            raise Decidim::Api::Errors::AttributeValidationError, form.errors
          end
        end
      end

      def authorized?(attributes:)
        unless super && allowed_to?(:update, :budget, object, { current_user:, budget: object })
          raise Decidim::Api::Errors::MutationNotAuthorizedError, I18n.t("decidim.api.errors.unauthorized_mutation")
        end

        true
      end

      def self.permission_chain(object)
        super.unshift(Decidim::Budgets::Admin::Permissions)
      end

      private

      def extract_from(attributes)
        validate_multiple_locales(attributes, :title)
        validate_multiple_locales(attributes, :description)

        attributes = attributes.to_h.reverse_merge(
          weight: object.weight,
          total_budget: object.total_budget,
          decidim_scope_id: object.scope&.id
        )

        attributes.to_h[:title] = (attributes.to_h.fetch(:title, {}).presence || {}).reverse_merge(object.title)
        attributes.to_h[:description] = (attributes.to_h.fetch(:description, {}).presence || {}).reverse_merge(object.description)

        attributes
      end
    end
  end
end
