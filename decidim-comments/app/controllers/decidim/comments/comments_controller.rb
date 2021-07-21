# frozen_string_literal: true

module Decidim
  module Comments
    # Controller that manages the comments for a commentable object.
    #
    class CommentsController < Decidim::Comments::ApplicationController
      include Decidim::ResourceHelper

      before_action :authenticate_user!, only: [:create]
      before_action :set_commentable
      before_action :ensure_commentable!

      helper_method :root_depth, :commentable, :order, :reply?, :reload?

      def index
        enforce_permission_to :read, :comment, commentable: commentable

        @comments = SortedComments.for(
          commentable,
          order_by: order,
          after: params.fetch(:after, 0).to_i
        )
        @comments_count = commentable.comments_count

        respond_to do |format|
          format.js do
            if reload?
              render :reload
            else
              render :index
            end
          end

          # This makes sure bots are not causing unnecessary log entries.
          format.html { redirect_to commentable_path }
        end
      end

      def create
        enforce_permission_to :create, :comment, commentable: commentable

        form = Decidim::Comments::CommentForm.from_params(
          params.merge(commentable: commentable)
        ).with_context(
          current_organization: current_organization,
          current_component: current_component
        )
        Decidim::Comments::CreateComment.call(form, current_user) do
          on(:ok) do |comment|
            handle_success(comment)
            respond_to do |format|
              format.js { render :create }
            end
          end

          on(:invalid) do
            @error = t("create.error", scope: "decidim.comments.comments")
            respond_to do |format|
              format.js { render :error }
            end
          end
        end
      end

      def current_component
        return commentable.component if commentable.respond_to?(:component)
        return commentable.participatory_space if commentable.respond_to?(:participatory_space)
        return commentable if Decidim.participatory_space_manifests.find { |manifest| manifest.model_class_name == commentable.class.name }
      end

      private

      attr_reader :commentable, :comment

      def set_commentable
        @commentable = GlobalID::Locator.locate_signed(commentable_gid)
      end

      def ensure_commentable!
        raise ActionController::RoutingError, "Not Found" unless commentable
      end

      def handle_success(comment)
        @comment = comment
        @comments_count = begin
          case commentable
          when Decidim::Comments::Comment
            commentable.root_commentable.comments_count
          else
            commentable.comments_count
          end
        end
      end

      def commentable_gid
        case action_name
        when "create"
          params.require(:comment).fetch(:commentable_gid)
        else
          params.fetch(:commentable_gid, nil)
        end
      end

      def reply?(comment)
        comment.root_commentable != comment.commentable
      end

      def order
        params.fetch(:order, "older")
      end

      def reload?
        params.fetch(:reload, 0).to_i == 1
      end

      def root_depth
        params.fetch(:root_depth, 0).to_i
      end

      def commentable_path
        return commentable.polymorphic_resource_path({}) if commentable&.respond_to?(:polymorphic_resource_path)

        resource_locator(commentable).path
      end
    end
  end
end
