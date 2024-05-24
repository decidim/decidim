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

        ids = []
        follows = Decidim::Follow.where(user: resource.decidim_user_id)
        ids << find_space_follow_id(follows, resource, space)
        ids << find_children_follows_ids(follows, space)
        follows.where(id: ids.flatten.compact).destroy_all if ids.present?
      end

      def find_space_follow_id(follows, resource, space)
        follows.where(decidim_followable_type: resource.privatable_to_type)
               .where(decidim_followable_id: space.id)
               &.first&.id
      end

      def find_children_follows_ids(follows, space)
        follows.map do |follow|
          object = find_object_followed(follow).presence
          next unless object.respond_to?("decidim_component_id")

          follow.id if space.components.ids.include?(object.decidim_component_id)
        end
      end

      def find_object_followed(follow)
        follow.decidim_followable_type.constantize.find(follow.decidim_followable_id)
      end
    end
  end
end
