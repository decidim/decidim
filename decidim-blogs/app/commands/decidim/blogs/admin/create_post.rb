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
      end
    end
  end
end
