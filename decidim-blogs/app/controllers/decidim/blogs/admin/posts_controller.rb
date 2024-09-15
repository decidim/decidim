# frozen_string_literal: true

module Decidim
  module Blogs
    module Admin
      # This controller allows the create or update a blog.
      class PostsController < Admin::ApplicationController
        helper UserGroupHelper
        helper PostsHelper

        helper_method :deleted_posts

        def new
          enforce_permission_to :create, :blogpost
          @form = form(PostForm).instance
        end

        def create
          enforce_permission_to :create, :blogpost
          @form = form(PostForm).from_params(params, current_component:)

          CreatePost.call(@form) do
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
          @form = form(PostForm).from_params(params, current_component:)

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
          enforce_permission_to :destroy, :blogpost, blogpost: post

          Decidim::Commands::DestroyResource.call(post, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("posts.destroy.success", scope: "decidim.blogs.admin")
              redirect_to posts_path
            end
          end
        end

        def soft_delete
          enforce_permission_to :soft_delete, :blogpost, blogpost: post

          Decidim::Commands::SoftDeleteResource.call(post, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("posts.soft_delete.success", scope: "decidim.blogs.admin")
              redirect_to posts_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("posts.soft_delete.invalid", scope: "decidim.blogs.admin")
              redirect_to posts_path
            end
          end
        end

        def restore
          enforce_permission_to :restore, :blogpost, blogpost: post

          Decidim::Commands::RestoreResource.call(post, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("posts.restore.success", scope: "decidim.blogs.admin")
              redirect_to posts_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("posts.restore.invalid", scope: "decidim.blogs.admin")
              redirect_to deleted_posts_path
            end
          end
        end

        def deleted
          enforce_permission_to :index, :blogpost
        end

        private

        def post
          @post ||= Blogs::Post.find_by(component: current_component, id: params[:id])
        end

        def deleted_posts
          @deleted_posts ||= Post.where(component: current_component).trashed.page(params[:page]).per(15)
        end
      end
    end
  end
end
