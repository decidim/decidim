# frozen_string_literal: true

module Decidim
  module Accountability
    class CreateMilestoneType < Decidim::Api::Types::BaseMutation
      description "Creates a milestone"
      type Decidim::Accountability::MilestoneType

      argument :attributes, MilestoneAttributes, description: "input attributes of a milestone", required: true

      def resolve(attributes:)
        form_attrs = attributes.to_h.merge(
          decidim_accountability_result_id: object.id
        )
        form = Admin::MilestoneForm.from_params(form_attrs).with_context(
          current_component: object.component,
          current_user: context[:current_user],
          current_organization: object.organization
        )
        handle_form_submission do
          Admin::CreateMilestone.call(form)
        end
      end

      def authorized?(attributes:)
        super && allowed_to?(:create, :milestone, object, context, scope: :admin)
      end
    end
  end
end
