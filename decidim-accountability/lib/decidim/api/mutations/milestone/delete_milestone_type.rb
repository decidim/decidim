# frozen_string_literal: true

module Decidim
  module Accountability
    class DeleteMilestoneType < Api::DestroyResourceType
      description "Deletes a milestone"

      type Decidim::Accountability::MilestoneType

      required_scopes "admin:read", "admin:write"

      def self.scope = :admin

      def authorized?(id:)
        milestone = find_resource(id)

        unless super && allowed_to?(:destroy, :milestone, milestone, context) # && user_can_perform_admin_actions?(current_user)
          raise Decidim::Api::Errors::MutationNotAuthorizedError, I18n.t("decidim.api.errors.unauthorized_mutation")
        end

        true
      end

      def self.permission_chain(object)
        super.unshift(Decidim::Accountability::Admin::Permissions)
      end

      private

      def find_resource(id = nil)
        context[:milestone] ||= object.milestones.find(id)
      end
    end
  end
end
