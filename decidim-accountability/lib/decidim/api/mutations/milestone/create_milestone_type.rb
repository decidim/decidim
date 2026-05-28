# frozen_string_literal: true

module Decidim
  module Accountability
    class CreateMilestoneType < Decidim::Api::Types::BaseMutation
      graphql_name "CreateMilestone"

      description "Creates a milestone"
      type Decidim::Accountability::MilestoneType

      required_scopes "admin:read", "admin:write"

      argument :attributes, MilestoneAttributes, description: "Input attributes for creating a milestone", required: true

      def resolve(attributes:)
        params = extract_from(attributes)

        form = form(Admin::MilestoneForm).from_params(params, milestone: object)

        Admin::CreateMilestone.call(form) do
          on(:ok, resource) do
            return resource
          end

          on(:invalid) do
            raise Decidim::Api::Errors::AttributeValidationError, form.errors
          end
        end
      end

      def authorized?(attributes:)
        unless super && allowed_to?(:create, :milestone, object, { current_user:, current_component: })
          raise Decidim::Api::Errors::MutationNotAuthorizedError, I18n.t("decidim.api.errors.unauthorized_mutation")
        end

        true
      end

      def self.permission_chain(object)
        super.unshift(Decidim::Accountability::Admin::Permissions)
      end

      private

      def extract_from(attributes)
        validate_multiple_locales(attributes, :title)
        validate_multiple_locales(attributes, :description)

        attributes = attributes.to_h
        attributes[:decidim_accountability_result_id] = object.id

        attributes[:title] = attributes.to_h.fetch(:title, {})
        attributes[:description] = attributes.to_h.fetch(:description, {})
        attributes[:entry_date] = attributes.to_h.fetch(:entry_date, nil)

        attributes
      end
    end
  end
end
