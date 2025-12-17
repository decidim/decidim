# frozen_string_literal: true

module Decidim
  module Proposals
    class UpdateProposalType < Decidim::Api::Types::BaseMutation
      graphql_name "UpdateProposal"

      description "Updates a proposal"
      type Decidim::Proposals::ProposalType

      argument :attributes, ProposalAttributes, description: "Input attributes for updating a proposal", required: true
      argument :locale, GraphQL::Types::String, "The locale for which to get the proposals texts", required: true
      argument :toggle_translations, GraphQL::Types::Boolean, "Whether the user asked to toggle the machine translations or not.", required: true, default_value: false

      def resolve(attributes:, locale:, toggle_translations:)
        set_locale(locale:, toggle_translations:)

        title = attributes.to_h.fetch(:title, object.title)
        body = attributes.to_h.fetch(:body, object.body)
        address = attributes.to_h.fetch(:address, object.address)
        latitude = attributes.to_h.fetch(:latitude, object.latitude)
        longitude = attributes.to_h.fetch(:longitude, object.longitude)
        taxonomies = attributes.to_h.fetch(:taxonomies, object.taxonomies)

        params = {
          title:,
          body:,
          address:,
          latitude:,
          longitude:,
          taxonomies:
        }

        params[:taxonomies] = Decidim::Taxonomy.where(id: params[:taxonomies]).pluck(:id) if params[:taxonomies]

        form = Decidim::Proposals::ProposalForm.from_params(
          params
        ).with_context(
          current_component: object.component,
          current_user:,
          current_organization: current_user.organization,
          current_participatory_space: object.component.participatory_space
        )

        UpdateProposal.call(form, current_user, object) do
          on(:ok) do |proposal|
            return proposal
          end
          on(:invalid) do
            raise Decidim::Api::Errors::AttributeValidationError, form.errors
          end
        end
      end

      def authorized?(attributes:)
        raise Decidim::Api::Errors::MutationNotAuthorizedError, I18n.t("decidim.api.errors.unauthorized_mutation") unless super && allowed_to?(:edit, :proposal, object, context)

        true
      end
    end
  end
end
