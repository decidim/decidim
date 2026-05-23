# frozen_string_literal: true

module Decidim
  module Accountability
    class UpdateMilestoneType < Decidim::Api::Types::BaseMutation
      description "Updates a milestone"
      type Decidim::Accountability::MilestoneType

      required_scopes "admin:read", "admin:write"

      argument :attributes, MilestoneAttributes, description: "Input attributes to update a milestone", required: true
      argument :id, GraphQL::Types::ID, "The ID of the milestone", required: true

      def resolve(attributes:, id:)
        params = extract_from(attributes)

        form = form(Admin::MilestoneForm).from_params(params)

        Admin::UpdateMilestone.call(form, milestone(id)) do
          on(:ok, resource) do
            return resource.reload
          end

          on(:invalid) do
            raise Decidim::Api::Errors::AttributeValidationError, form.errors
          end
        end
      end

      def authorized?(attributes:, id:)
        unless super && allowed_to?(:update, :milestone, milestone(id), context) &&
               user_can_perform_admin_actions?(context[:current_user])
          raise Decidim::Api::Errors::MutationNotAuthorizedError, I18n.t("decidim.api.errors.unauthorized_mutation")
        end

        true
      end

      def self.permission_chain(object)
        super.unshift(Decidim::Accountability::Admin::Permissions)
      end

      private

      def milestone(id = nil)
        context[:milestone] ||= begin
          id ||= arguments[:id]
          object.milestones.find(id)
        end
      end

      def extract_from(attributes)
        validate_multiple_locales(attributes, :title)
        validate_multiple_locales(attributes, :description)

        attributes = attributes.to_h
        attributes[:decidim_accountability_result_id] = object.id

        attributes[:title] = attributes.to_h.fetch(:title, context[:milestone].title)
        attributes[:description] = attributes.to_h.fetch(:description, context[:milestone].description)
        attributes[:entry_date] = attributes.to_h.fetch(:entry_date, context[:milestone].entry_date)

        attributes
      end
    end
  end
end
