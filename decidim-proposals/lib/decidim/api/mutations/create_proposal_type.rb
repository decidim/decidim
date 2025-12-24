# frozen_string_literal: true

module Decidim
  module Proposals
    class CreateProposalType < Decidim::Api::Types::BaseMutation
      graphql_name "CreateProposal"

      description "Creates a proposal"
      type Decidim::Proposals::ProposalType

      argument :attributes, ProposalAttributes, description: "Input attributes for the proposal", required: true
      argument :locale, GraphQL::Types::String, "The locale for which to set the proposal texts", required: true
      argument :toggle_translations, GraphQL::Types::Boolean, "Whether the user asked to toggle the machine translations or not.", required: false, default_value: false

      def resolve(attributes:, locale:, toggle_translations:)
        set_locale(locale:, toggle_translations:)

        params = extract_from(attributes)

        form = form(Decidim::Proposals::ProposalForm).from_params(params)

        Decidim::Proposals::CreateProposal.call(form, current_user) do
          on(:ok) do |proposal|
            Decidim::Proposals::PublishProposal.call(proposal, current_user) do
              on(:ok) do
                return proposal.reload
              end

              on(:invalid) do
                raise Decidim::Api::Errors::ValidationError, I18n.t("proposals.publish.error", scope: "decidim")
              end
            end
          end

          on(:invalid) do
            raise Decidim::Api::Errors::AttributeValidationError, form.errors
          end
        end
      end

      def authorized?(attributes:, locale:, toggle_translations:)
        unless super && allowed_to?(:create, :proposal, Decidim::Proposals::Proposal.new(component: current_component), { current_user:, current_component: })
          raise Decidim::Api::Errors::MutationNotAuthorizedError, I18n.t("decidim.api.errors.unauthorized_mutation")
        end

        true
      end

      private

      def extract_from(attributes)
        title = attributes.to_h.fetch(:title, translated_attribute(object.title))
        body = attributes.to_h.fetch(:title, translated_attribute(object.body))
        taxonomies = Decidim::Taxonomy.where(organization: current_organization, id: attributes.to_h.fetch(:taxonomies, [])).pluck(:id)
        address = attributes.to_h.fetch(:address, object.address)
        latitude = attributes.to_h.fetch(:latitude, object.latitude)
        longitude = attributes.to_h.fetch(:longitude, object.longitude)

        { title:, body:, address:, latitude:, longitude:, taxonomies: }
      end
    end
  end
end
