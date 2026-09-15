# frozen_string_literal: true

module Decidim
  module Accountability
    class CreateResultType < Decidim::Api::Types::BaseMutation
      description "Creates a result"
      type Decidim::Accountability::ResultType

      required_scopes "admin:read", "admin:write"

      argument :attributes, ResultAttributes, description: "Input attributes for creating a result", required: true

      def resolve(attributes:)
        params = extract_from(attributes)

        form = form(Admin::ResultForm).from_params(params)

        Admin::CreateResult.call(form) do
          on(:ok, resource) do
            return resource.reload
          end

          on(:invalid) do
            raise Decidim::Api::Errors::AttributeValidationError, form.errors
          end
        end
      end

      def authorized?(attributes:)
        raise Decidim::Api::Errors::MutationNotAuthorizedError, I18n.t("decidim.api.errors.unauthorized_mutation") unless super && allowed_to?(:create, :result, object, context)

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

        attributes[:title] = attributes.to_h.fetch(:title, {})
        attributes[:description] = attributes.to_h.fetch(:description, {})
        attributes[:taxonomies] = Decidim::Taxonomy.where(organization: current_organization, id: attributes[:taxonomies]).pluck(:id) if attributes[:taxonomies]

        attributes
      end
    end
  end
end
