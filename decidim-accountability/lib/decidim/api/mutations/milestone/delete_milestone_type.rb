# frozen_string_literal: true

module Decidim
  module Accountability
    class DeleteMilestoneType < Api::DestroyResourceType
      description "deletes a milestone"

      type Decidim::Accountability::MilestoneType

      def authorized?(id:)
        milestone = find_resource(id)

        super && allowed_to?(:destroy, :milestone, milestone, context, scope: :admin) &&
          user_can_perform_admin_actions?(context[:current_user])
      end

      private

      def find_resource(id = nil)
        context[:milestone] ||= begin
          id ||= arguments[:id]
          object.milestones.find_by(id:)
        end
      end
    end
  end
end
