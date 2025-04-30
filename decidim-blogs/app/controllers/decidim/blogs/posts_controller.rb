# frozen_string_literal: true

module Decidim
  module Blogs
    # Exposes the blog resource so users can view them
    class PostsController < Decidim::Blogs::ApplicationController
      include Flaggable
      include Paginable
      include Decidim::IconHelper

      helper Decidim::Blogs::PostsSelectHelper
      include Decidim::FormFactory

      helper_method :posts, :post, :post_presenter, :paginate_posts, :posts_most_commented, :tabs, :panels

      def index; end

      def show
        raise ActionController::RoutingError, "Not Found" unless post
      end

      def new
        enforce_permission_to :create, :blogpost
        @form = form(Decidim::Blogs::PostForm).instance
      end

      def create
        enforce_permission_to :create, :blogpost
        @form = form(Decidim::Blogs::PostForm).from_params(params, current_component: current_component)

        CreatePost.call(@form) do
          on(:ok) do |new_post|
            flash[:notice] = I18n.t("posts.create.success", scope: "decidim.blogs.admin")
            redirect_to post_path(new_post)
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

        UpdatePost.call(@form, post) do
          on(:ok) do |post|
            flash[:notice] = I18n.t("posts.update.success", scope: "decidim.blogs.admin")
            redirect_to post_path(post)
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

      def paginate_posts
        @paginate_posts ||= paginate(posts.created_at_desc)
      end

      def post
        @post ||= posts.find(params[:id])
      end

      def post_presenter
        @post_presenter ||= PostPresenter.new(post)
      end

      def posts
        @posts ||= if current_user&.admin?
                     Post.where(component: current_component)
                   else
                     Post.published.where(component: current_component)
                   end
      end

      # PROVISIONAL if we implement counter cache
      def posts_most_commented
        @posts_most_commented ||= posts.joins(:comments).group(:id)
                                       .select("count(decidim_comments_comments.id) as counter")
                                       .select("decidim_blogs_posts.*").order("counter DESC").created_at_desc.limit(7)
      end
    end
  end
end
