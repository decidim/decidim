# frozen_string_literal: true

module Decidim
  module Blogs
    class PublishPostJob < ApplicationJob
      def perform(post_id, published_date)
        resource = Decidim::Blogs::Post.find(post_id)

        return unless resource.published?
        return unless resource.published_at == published_date

        Decidim.traceability.perform_action!(:publish, resource, resource.author, visibility: "all") do
          resource
        end

        Decidim::EventsManager.publish(
          event: "decidim.events.blogs.post_created",
          event_class: Decidim::Blogs::CreatePostEvent,
          resource:,
          followers: resource.participatory_space.followers
        )
      end
    end
  end
end
