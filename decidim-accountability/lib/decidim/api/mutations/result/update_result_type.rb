# frozen_string_literal: true

module Decidim
  module Accountability
    class UpdateResultType < Decidim::Api::Types::BaseMutation
      description "Updates a result"
      type Decidim::Accountability::ResultType

      argument :attributes, ResultAttributes, description: "Input attributes to update a result", required: true

      required_scopes "admin:read", "admin:write"

      def resolve(attributes:)
        params = extract_from(attributes)

        form = form(Admin::ResultForm).from_params(params)

        Admin::UpdateResult.call(form, object) do
          on(:ok, resource) do
            return resource.reload
          end

          on(:invalid) do
            raise Decidim::Api::Errors::AttributeValidationError, form.errors
          end
        end
      end

      def authorized?(attributes:)
        unless super && allowed_to?(:update, :result, object, { current_user:, result: object })
          raise Decidim::Api::Errors::MutationNotAuthorizedError, I18n.t("decidim.api.errors.unauthorized_mutation")
        end

        true
      end

      def self.permission_chain(object)
        super.unshift(Decidim::Accountability::Admin::Permissions)
      end

      private

      def linked_resources(result, type)
        case type
        when :proposals
          result.linked_resources(:proposals, "included_proposals")
        when :projects
          result.linked_resources(:projects, "included_projects")
        end
          .pluck(:id)
      end

      def extract_from(attributes)
        validate_multiple_locales(attributes, :title)
        validate_multiple_locales(attributes, :description)

        attributes = attributes.to_h.reverse_merge(
          decidim_accountability_status_id: object.status&.id,
          end_date: object.end_date,
          external_id: object.external_id,
          parent_id: object.parent&.id,
          progress: object.progress,
          project_ids: linked_resources(object, :projects),
          proposal_ids: linked_resources(object, :proposals),
          start_date: object.start_date,
          taxonomies: object.taxonomies.map(&:id),
          weight: object.weight
        )
        attributes[:title] = (attributes.fetch(:title, {}).presence || {}).reverse_merge(object.title)
        attributes[:description] = (attributes.fetch(:description, {}).presence || {}).reverse_merge(object.description)

        attributes
      end
    end
  end
end
