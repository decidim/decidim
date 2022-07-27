# frozen_string_literal: true

module Decidim
  module Blogs
    module Admin
      # This command is executed when the user changes a Blog from the admin
      # panel.
      class UpdatePost < Decidim::Command
        # Initializes a UpdateBlog Command.
        #
        # form - The form from which to get the data.
        # blog - The current instance of the page to be updated.
        def initialize(form, post, user)
          @form = form
          @post = post
          @user = user
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
          Decidim.traceability.update!(
            post,
            @user,
            title: form.title,
            body: form.body,
            author: form.author
          )
        end
      end
    end
  end
end
