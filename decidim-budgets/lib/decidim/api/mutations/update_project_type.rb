# frozen_string_literal: true

module Decidim
  module Budgets
    class UpdateProjectType < Decidim::Api::Types::BaseMutation
      description "Update a project"
      type Decidim::Budgets::ProjectType

      argument :attributes, ProjectAttributes, description: "input attributes to update a project", required: true
      argument :id, GraphQL::Types::ID, "The ID of the project", required: true

      def resolve(attributes:, id:) # rubocop:disable Lint/UnusedMethodArgument
        form_attrs = attributes.to_h.reverse_merge(
          address: project.address,
          budget_amount: project.budget_amount,
          description: project.description,
          longitude: project.longitude,
          latitude: project.latitude,
          title: project.title,
          proposal_ids: project.linked_resources(:proposals, "included_proposals").map(&:id),
          taxonomies: project.taxonomies.map(&:id)
        )

        form = form(Admin::ProjectForm).from_params(form_attrs)

        Admin::UpdateProject.call(form, project) do
          on(:ok, resource) do
            return resource
          end

          on(:invalid) do
            raise Decidim::Api::Errors::AttributeValidationError, form.errors
          end
        end
      end

      def authorized?(attributes:, id:)
        unless super && allowed_to?(:update, :project, project(id), { project: project(id), current_user: }, scope: :admin)
          raise Decidim::Api::Errors::MutationNotAuthorizedError, I18n.t("decidim.api.errors.unauthorized_mutation")
        end

        true
      end

      private

      def project(id = nil)
        context[:project] ||= begin
          id ||= arguments[:id]
          object.projects.find_by(id:)
        end
      end
    end
  end
end
