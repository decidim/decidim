# frozen_string_literal: true

module Decidim
  module Budgets
    class UpdateProjectType < Decidim::Api::Types::BaseMutation
      description "Update a project"
      type Decidim::Budgets::ProjectType

      argument :attributes, ProjectAttributes, description: "input attributes to update a project", required: true
      argument :id, GraphQL::Types::ID, "The ID of the project", required: true

      def resolve(attributes:, id:)
        params = extract_from(attributes)

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
        unless super && allowed_to?(:update, :project, project(id), { project: project(id), current_user: }, scope: :admin)
          raise Decidim::Api::Errors::MutationNotAuthorizedError, I18n.t("decidim.api.errors.unauthorized_mutation")
        end

        true
      end

      private

      def project(id = nil)
        context[:project] ||= object.projects.find_by(id:)
      end

      private

      def extract_from(attributes)
        validate_multiple_locales(attributes, :title)
        validate_multiple_locales(attributes, :description)

        attributes = attributes.to_h.reverse_merge(
          address: context[:project].address,
          longitude: context[:project].longitude,
          latitude: context[:project].latitude,
          budget_amount: context[:project].budget_amount
        )

        attributes[:title] = attributes.to_h.fetch(:title, context[:project].title)
        attributes[:description] = attributes.to_h.fetch(:description, context[:project].description)
        attributes[:proposal_ids] = attributes.to_h.fetch(:proposal_ids, context[:project].linked_resources(:proposals, "included_proposals").map(&:id))

        attributes[:taxonomies] = attributes.to_h.fetch(:taxonomies, context[:project].taxonomies.map(&:id))
        attributes[:taxonomies] = Decidim::Taxonomy.where(organization: current_organization, id: attributes[:taxonomies]).pluck(:id) if attributes[:taxonomies]

        attributes
      end
    end
  end
end
