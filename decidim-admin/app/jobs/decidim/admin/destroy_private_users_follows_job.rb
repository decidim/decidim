# frozen_string_literal: true

module Decidim
  module Admin
    # Custom ApplicationJob scoped to the admin panel.
    #
    class DestroyPrivateUsersFollowsJob < ApplicationJob
      queue_as :default

      def perform(decidim_user_id, privatable_to_type, space)
        follows = Decidim::Follow.where(user: decidim_user_id)
        destroy_space_follow(follows, privatable_to_type, space)
        destroy_children_follows(follows, space)
      end

      def destroy_space_follow(follows, privatable_to_type, space)
        follows.where(decidim_followable_type: privatable_to_type)
               .where(decidim_followable_id: space.id).destroy_all
      end

      def destroy_children_follows(follows, space)
        follows.map do |follow|
          object = find_object_followed(follow).presence
          next unless object.respond_to?("decidim_component_id")

          follow.destroy if space.component_ids.include?(object.decidim_component_id)
        end
      end

      def find_object_followed(follow)
        follow.decidim_followable_type.constantize.find(follow.decidim_followable_id)
      end
    end
  end
end
