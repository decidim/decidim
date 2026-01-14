# frozen_string_literal: true

module Decidim
  module Debates
    class UpdateDebateType < Decidim::Api::Types::BaseMutation
      graphql_name "UpdateDebate"

      description "Updates a debate"
      type Decidim::Debates::DebateType

      argument :attributes, DebateAttributes, description: "input attributes of a debate", required: true
      argument :locale, GraphQL::Types::String, "The locale for which to set the debate texts", required: true
      argument :toggle_translations, GraphQL::Types::Boolean, "Whether the user asked to toggle the machine translations or not.", required: false, default_value: false

      def resolve(attributes:, locale:, toggle_translations:)
        set_locale(locale:, toggle_translations:)

        params = extract_from(attributes)
        params[:taxonomies] = Decidim::Taxonomy.where(organization: current_organization, id: params[:taxonomies]).pluck(:id) if params[:taxonomies]

        form = form(Decidim::Debates::DebateForm).from_params(params)

        UpdateDebate.call(form, object) do
          on(:ok) do
            return object.reload
          end

          on(:invalid) do
            raise Decidim::Api::Errors::AttributeValidationError, form.errors
          end
        end
      end

      def authorized?(attributes:, locale:, toggle_translations:)
        raise Decidim::Api::Errors::MutationNotAuthorizedError, I18n.t("decidim.api.errors.unauthorized_mutation") unless super && allowed_to?(:edit, :debate, object, context)

        true
      end

      private

      def extract_from(attributes)
        attributes = attributes.to_h.compact

        title = attributes.fetch(:title, translated_attribute(object.title))
        description = attributes.fetch(:description, translated_attribute(object.description))
        taxonomies = attributes.fetch(:taxonomies, object.taxonomies.pluck(:id))

        {
          title:,
          description:,
          taxonomies:
        }
      end
    end
  end
end
