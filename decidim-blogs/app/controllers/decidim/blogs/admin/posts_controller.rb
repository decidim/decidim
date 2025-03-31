# frozen_string_literal: true

module Decidim
  module Blogs
    module Admin
      # This controller allows the create or update a blog.
      class PostsController < Admin::ApplicationController
        include Decidim::Admin::HasTrashableResources

        helper PostsHelper

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

        private

        def trashable_deleted_resource_type
          :post
        end

        def trashable_deleted_resource
          @trashable_deleted_resource ||= Blogs::Post.with_deleted.find_by(component: current_component, id: params[:id])
        end

        def trashable_deleted_collection
          @trashable_deleted_collection ||= Post.where(component: current_component).only_deleted.deleted_at_desc.page(params[:page]).per(15)
        end

        def post
          @post ||= Blogs::Post.find_by(component: current_component, id: params[:id])
        end
      end
    end
  end
end
