# frozen_string_literal: true

module Decidim
  module Debates
    class CreateDebateType < Decidim::Api::Types::BaseMutation
      graphql_name "CreateDebate"

      description "Creates a debate"
      type Decidim::Debates::DebateType

      argument :attributes, DebateAttributes, description: "Input attributes of a debate", required: true
      argument :locale, GraphQL::Types::String, "The locale for which to set the debate texts", required: true
      argument :toggle_translations, GraphQL::Types::Boolean, "Whether the user asked to toggle the machine translations or not.", required: false, default_value: false

      def resolve(attributes:, locale:, toggle_translations:)
        set_locale(locale:, toggle_translations:)

        params = attributes.to_h.slice(:title, :description)

        params[:taxonomies] = Decidim::Taxonomy.where(organization: current_organization, id: attributes.to_h.fetch(:taxonomies, [])).pluck(:id)

        form = form(Decidim::Debates::DebateForm).from_params(params)

        Decidim::Debates::CreateDebate.call(form) do
          on(:ok) do |debate|
            return debate.reload
          end

          on(:invalid) do
            raise Decidim::Api::Errors::AttributeValidationError, form.errors
          end
        end
      end

      def authorized?(attributes:, locale:, toggle_translations:)
        unless super && allowed_to?(:create, :debate, Debate.new(component: current_component), { current_user:, current_component: })
          raise Decidim::Api::Errors::MutationNotAuthorizedError, I18n.t("decidim.api.errors.unauthorized_mutation")
        end

        true
      end
    end
  end
end
