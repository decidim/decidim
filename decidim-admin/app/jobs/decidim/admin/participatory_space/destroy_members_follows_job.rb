# frozen_string_literal: true

module Decidim
  module Admin
    module ParticipatorySpace
      class DestroyMembersFollowsJob < ApplicationJob
        queue_as :default

        def perform(decidim_user_id, space)
          return unless space.respond_to?(:restricted?) && space.restricted?
          return if space.respond_to?(:transparent?) && space.transparent?

          user = Decidim::User.find_by(id: decidim_user_id)

          return if user.blank?

          return if space.respond_to?(:can_participate?) && space.can_participate?(user)

          follows = Decidim::Follow.where(user:)
          follows.where(followable: space).destroy_all

          destroy_children_follows(follows, space)
        end

        def destroy_children_follows(follows, space)
          follows.map do |follow|
            object = follow.followable.presence
            next unless object.respond_to?(:decidim_component_id)

            follow.destroy if space.component_ids.include?(object.decidim_component_id)
          end
        end
      end
    end
  end
end
