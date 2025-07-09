# frozen_string_literal: true

module Decidim
  module Accountability
    class UpdateMilestoneType < Decidim::Api::Types::BaseMutation
      description "updates a milestone"
      type Decidim::Accountability::MilestoneType

      argument :attributes, MilestoneAttributes, description: "input attributes of a milestone", required: true
      argument :id, GraphQL::Types::ID, "The ID of the milestone", required: true

      def resolve(attributes:, id:)
        form_attrs = attributes.to_h.reverse_merge(
          decidim_accountability_result_id: object.id,
          title: milestone.title,
          description: milestone.description,
          entry_date: milestone.entry_date
        )
        form = Admin::MilestoneForm.from_params(form_attrs).with_context(
          current_component: object.component,
          current_user: context[:current_user],
          current_organization: object.organization
        )
        handle_form_submission do
          Admin::UpdateMilestone.call(form, milestone)
        end
      end

      def authorized?(attributes:, id:)
        super && allowed_to?(:update, :milestone, milestone(id), context, scope: :admin)
      end

      private

      def milestone(id = nil)
        context[:milestone] ||= begin
          id ||= arguments[:id]
          object.milestones.find_by(id:)
        end
      end
    end
  end
end
