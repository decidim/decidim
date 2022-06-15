# frozen_string_literal: true

module Decidim
  module Blogs
    module Admin
      # This controller allows the create or update a blog.
      class PostsController < Admin::ApplicationController
        helper UserGroupHelper

        def new
          enforce_permission_to :create, :blogpost
          @form = form(PostForm).instance
        end

        def create
          enforce_permission_to :create, :blogpost
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
          enforce_permission_to :update, :blogpost, blogpost: post
          @form = form(PostForm).from_model(post)
        end

        def update
          enforce_permission_to :update, :blogpost, blogpost: post
          @form = form(PostForm).from_params(params, current_component: current_component)

          UpdatePost.call(@form, post, current_user) do
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
          enforce_permission_to :destroy, :blogpost, blogpost: post

          Decidim.traceability.perform_action!("delete", post, current_user) do
            post.destroy!
          end

          flash[:notice] = I18n.t("posts.destroy.success", scope: "decidim.blogs.admin")

          redirect_to posts_path
        end

        private

        def post
          @post ||= Blogs::Post.find_by(component: current_component, id: params[:id])
        end
      end
    end
  end
end
