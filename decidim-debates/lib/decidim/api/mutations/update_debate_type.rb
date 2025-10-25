# frozen_string_literal: true

module Decidim
  module Debates
    class UpdateDebateType < Decidim::Api::Types::BaseMutation
      graphql_name "UpdateDebate"

      description "Updates a debate"
      type Decidim::Debates::DebateType

      argument :attributes, UpdateDebateAttributes, description: "input attributes of a debate", required: true

      def resolve(attributes:)
        title = attributes.to_h.fetch(:title, object.title.values.first)
        description = attributes.to_h.fetch(:description, object.description.values.first)
        taxonomy_ids = attributes.to_h.fetch(:taxonomy_ids, object.taxonomies.map(&:id))

        # Convert taxonomy IDs to taxonomy objects
        taxonomies = taxonomy_ids.present? ? Decidim::Taxonomy.where(id: taxonomy_ids).to_a : []

        params = {
          title:,
          description:,
          taxonomies:,
          id: object.id
        }

        form = Decidim::Debates::DebateForm.from_params(
          params
        ).with_context(
          current_component: object.component,
          current_user:,
          current_organization: current_user.organization,
          current_participatory_space: object.component.participatory_space
        )

        UpdateDebate.call(form, object) do
          on(:ok) do
            return object
          end
          on(:invalid) do
            return GraphQL::ExecutionError.new(
              form.errors.full_messages.join(", ")
            )
          end

          GraphQL::ExecutionError.new(
            I18n.t("decidim.debates.update.invalid")
          )
        end
      end

      def authorized?(attributes:)
        super && allowed_to?(:edit, :debate, { debate: object }, context)
      end

      def current_user
        context[:current_user]
      end
    end
  end
end
