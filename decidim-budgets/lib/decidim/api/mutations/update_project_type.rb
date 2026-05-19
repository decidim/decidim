# frozen_string_literal: true

module Decidim
  module Budgets
    class UpdateProjectType < Decidim::Api::Types::BaseMutation
      description "Updates a project"
      type Decidim::Budgets::ProjectType

      required_scopes "api:read", "admin:read", "admin:write"

      argument :attributes, ProjectAttributes, description: "Input attributes to update a project", required: true
      argument :id, GraphQL::Types::ID, "The ID of the project", required: true

      def resolve(attributes:, id:)
        project = project(id)
        params = extract_from(attributes, project)

        form = form(Admin::ProjectForm).from_params(params)

        Admin::UpdateProject.call(form, project) do
          on(:ok, resource) do
            return resource.reload
          end

          on(:invalid) do
            raise Decidim::Api::Errors::AttributeValidationError, form.errors
          end
        end
      rescue ActiveRecord::RecordNotSaved => e
        raise Decidim::Api::Errors::UnauthorizedObjectError, e.message
      end

      def authorized?(attributes:, id:)
        project = project(id)

        unless super && allowed_to?(:update, :project, project, { project:, current_user: })
          raise Decidim::Api::Errors::MutationNotAuthorizedError, I18n.t("decidim.api.errors.unauthorized_mutation")
        end

        true
      end

      def self.permission_chain(object)
        super.unshift(Decidim::Budgets::Admin::Permissions)
      end

      private

      def project(id = nil)
        context[:project] ||= object.projects.find(id)
      end

      def extract_from(attributes, project)
        validate_multiple_locales(attributes, :title)
        validate_multiple_locales(attributes, :description)

        attributes = attributes.to_h.reverse_merge(
          address: project.address,
          longitude: project.longitude,
          latitude: project.latitude,
          budget_amount: project.budget_amount
        )

        attributes[:title] = attributes.to_h.fetch(:title, project.title).presence || project.title
        attributes[:description] = attributes.to_h.fetch(:description, project.description).presence || project.description
        attributes[:proposal_ids] = attributes.to_h.fetch(:proposal_ids, project.linked_resources(:proposals, "included_proposals").map(&:id))

        attributes[:taxonomies] = attributes.to_h.fetch(:taxonomies, project.taxonomies.map(&:id))
        attributes[:taxonomies] = Decidim::Taxonomy.where(organization: current_organization, id: attributes[:taxonomies]).pluck(:id) if attributes[:taxonomies]

        attributes
      end
    end
  end
end
