# frozen_string_literal: true

module Decidim
  module Accountability
    class UpdateResultType < Decidim::Api::Types::BaseMutation
      description "Creates a result"
      type Decidim::Accountability::ResultType

      argument :attributes, ResultAttributes, description: "input attributes of a result", required: true
      argument :id, GraphQL::Types::ID, "The ID of the budget", required: true

      def resolve(attributes:, id:)
        form = form_from_attributes(attributes)

        handle_form_submission do
          Admin::UpdateResult.call(form, result)
        end
      end

      def authorized?(attributes:, id:)
        super && allowed_to?(:update, :result, result(id), context, scope: :admin)
      end

      private

      def result(id = nil)
        context[:result] ||= begin
          id ||= arguments[:id]
          Decidim::Accountability::Result.find_by(id:, component: object)
        end
      end

      def linked_resources(result, type)
        case type
        when :proposals
          result.linked_resources(:proposals, "included_proposals")
        when :projects
          result.linked_resources(:projects, "included_projects")
        end
          .pluck(:id)
      end

      def form_from_attributes(attributes)
        form_attrs = attributes.to_h.reverse_merge(
          decidim_accountability_status_id: result.status&.id,
          description: result.description,
          end_date: result.end_date,
          external_id: result.external_id,
          parent_id: result.parent&.id,
          progress: result.progress,
          project_ids: linked_resources(result, :projects),
          proposal_ids: linked_resources(result, :proposals),
          start_date: result.start_date,
          taxonomies: result.taxonomies.map(&:id),
          title: result.title,
          weight: result.weight
        )

        Admin::ResultForm.from_params(form_attrs).with_context(
          current_component: object,
          current_user: context[:current_user],
          current_organization: object.organization
        )
      end
    end
  end
end
