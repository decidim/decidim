# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic to destroy a participatory space private user.
    class DestroyParticipatorySpacePrivateUser < Decidim::Commands::DestroyResource
      private

      def extra_params
        {
          resource: {
            title: resource.user.name
          }
        }
      end

      def run_after_hooks
        # When private user is destroyed, a hook to destroy the follows of user on private non transparent assembly
        # or private participatory process and the follows of their children
        space = resource.privatable_to_type.constantize.find(resource.privatable_to_id)

        return unless space.private_space?

        return if space.respond_to?("is_transparent") && space.is_transparent?

        user = Decidim::User.find(resource.decidim_user_id)
        ids = []
        follows = Decidim::Follow.where(user:)
        ids << follows.where(decidim_followable_type: resource.privatable_to_type)
                      .where(decidim_followable_id: space.id)
                      &.first&.id
        children_ids = follows.select { |follow| find_object_followed(follow).respond_to?("decidim_component_id") }
                              .select { |follow| space.components.ids.include?(find_object_followed(follow).decidim_component_id) }
                              &.map(&:id)
        ids << children_ids

        follows.where(id: ids.flatten).destroy_all if ids.present?
      end

      def find_object_followed(follow)
        follow.decidim_followable_type.constantize.find(follow.decidim_followable_id)
      end
    end
  end
end
