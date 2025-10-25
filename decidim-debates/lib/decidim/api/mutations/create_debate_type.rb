# frozen_string_literal: true

module Decidim
  module Debates
    class CreateDebateType < Decidim::Api::Types::BaseMutation
      graphql_name "CreateDebate"

      description "Creates a debate"
      type Decidim::Debates::DebateType

      argument :component_id, GraphQL::Types::ID, description: "The ID of the component", required: true
      argument :attributes, CreateDebateAttributes, description: "Input attributes of a debate", required: true

      def resolve(component_id:, attributes:)
        component = Decidim::Component.find(component_id)
        
        title = attributes.to_h.fetch(:title)
        description = attributes.to_h.fetch(:description)
        taxonomy_ids = attributes.to_h.fetch(:taxonomy_ids, [])

        taxonomizations = taxonomy_ids.map do |taxonomy_id|
          taxonomy = Decidim::Taxonomy.find(taxonomy_id)
          Decidim::Taxonomization.new(taxonomy:, taxonomizable: nil)
        end

        params = {
          title:,
          description:,
          taxonomizations:
        }

        form = Decidim::Debates::DebateForm.from_params(params).with_context(
          current_component: component,
          current_user:,
          current_organization: current_user.organization
        )

        Decidim::Debates::CreateDebate.call(form) do
          on(:ok) do |debate|
            return debate
          end
          on(:invalid) do
            return GraphQL::ExecutionError.new(
              form.errors.full_messages.join(", ")
            )
          end

          GraphQL::ExecutionError.new(
            I18n.t("decidim.debates.create.invalid")
          )
        end
      end

      def authorized?(component_id:, attributes:)
        component = Decidim::Component.find(component_id)
        super && allowed_to?(:create, :debate, component:, context:)
      end

      def current_user
        context[:current_user]
      end
    end
  end
end
