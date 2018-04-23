# frozen_string_literal: true

module Decidim
  module Blogs
    module Admin
      # This controller allows the create or update a blog.
      class PostsController < Admin::ApplicationController
        def new
          @form = form(PostForm).instance
        end

        def create
          @form = form(PostForm).from_params(params, current_component: current_component)

          CreatePost.call(@form, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("posts.create.success", scope: "decidim.blogs.admin")
              redirect_to posts_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("posts.create.invalid", scope: "decidim.blogs.admin")
              render action: "new"
            end
          end
        end

        def edit
          @form = form(PostForm).from_model(post)
        end

        def update
          @form = form(PostForm).from_params(params, current_component: current_component)

          UpdatePost.call(@form, post) do
            on(:ok) do
              flash[:notice] = I18n.t("posts.update.success", scope: "decidim.blogs.admin")
              redirect_to posts_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("posts.update.invalid", scope: "decidim.blogs.admin")
              render action: "edit"
            end
          end
        end

        def destroy
          post.destroy!

          flash[:notice] = I18n.t("posts.destroy.success", scope: "decidim.blogs.admin")

          redirect_to posts_path
        end

        private

        def post
          @post ||= Blogs::Post.find_by(component: current_component)
        end
      end
    end
  end
end
