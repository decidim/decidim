# frozen_string_literal: true

module Decidim
  module Blogs
    module Admin
      # This command is executed when the user creates a Post from the admin
      # panel.
      class CreatePost < Decidim::Commands::CreateResource
        fetch_form_attributes :title, :body, :published_at, :author, :component, :taxonomizations

        private

        def resource_class = Decidim::Blogs::Post

        def extra_params = { visibility: "all" }

        def run_after_hooks
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
end
