# frozen_string_literal: true

module Decidim
  module Budgets
    class CreateProjectType < Decidim::Api::Types::BaseMutation
      graphql_name "CreateProject"

      description "Creates a project"
      type Decidim::Budgets::ProjectType

      required_scopes "api:read", "admin:read", "admin:write"

      argument :attributes, ProjectAttributes, description: "Input attributes for creating a project", required: true

      def resolve(attributes:)
        params = extract_from(attributes)

        form = form(Admin::ProjectForm).from_params(params, budget: object)

        Admin::CreateProject.call(form) do
          on(:ok, resource) do
            return resource
          end

          on(:invalid) do
            raise Decidim::Api::Errors::AttributeValidationError, form.errors
          end
        end
      end

      def authorized?(attributes:)
        unless super && allowed_to?(:create, :project, object, { current_user:, current_component: })
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

        attributes = attributes.to_h

        attributes[:title] = attributes.to_h.fetch(:title, {})
        attributes[:description] = attributes.to_h.fetch(:description, {})
        attributes[:latitude] = attributes.to_h.fetch(:latitude, nil)
        attributes[:longitude] = attributes.to_h.fetch(:longitude, nil)
        attributes[:taxonomies] = Decidim::Taxonomy.where(organization: current_organization, id: attributes[:taxonomies]).pluck(:id) if attributes[:taxonomies]

        attributes
      end
    end
  end
end
