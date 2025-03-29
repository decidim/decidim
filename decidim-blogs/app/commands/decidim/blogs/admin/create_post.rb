# frozen_string_literal: true

module Decidim
  module Blogs
    module Admin
      # This command is executed when the user creates a Post from the admin
      # panel.
      class CreatePost < Decidim::Commands::CreateResource
        fetch_form_attributes :title, :body, :published_at, :author, :component

        private

        def resource_class = Decidim::Blogs::Post

        def extra_params = { visibility: "all" }

        def run_after_hooks
          resource.reload
          Decidim::Blogs::PublishPostJob.set(wait_until: resource.published_at).perform_later(
            resource.id,
            current_user,
            resource.published_at
          )
        end
      end
    end
  end
end
