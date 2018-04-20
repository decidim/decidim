# frozen_string_literal: true

module Decidim
  module Blogs
    module Admin
      # This command is executed when the user changes a Blog from the admin
      # panel.
      class UpdatePost < Rectify::Command
        # Initializes a UpdateBlog Command.
        #
        # form - The form from which to get the data.
        # blog - The current instance of the page to be updated.
        def initialize(form, post)
          @form = form
          @post = post
        end

        # Updates the blog if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if form.invalid?

          transaction do
            update_post!
          end

          broadcast(:ok, post)
        end

        private

        attr_reader :form, :post

        def update_post!
          post.update!(
            title: form.title,
            body: form.body
          )
        end
      end
    end
  end
end
