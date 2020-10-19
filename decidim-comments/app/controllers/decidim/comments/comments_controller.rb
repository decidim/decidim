# frozen_string_literal: true

module Decidim
  module Comments
    # Controller that manages the comments for a commentable object.
    #
    class CommentsController < Decidim::Comments::ApplicationController
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
        @comments_count = commentable.comments.count

        render :reload if reload?
      end

      def create
        enforce_permission_to :create, :comment, commentable: commentable

        form = Decidim::Comments::CommentForm.from_params(
          params.merge(commentable: commentable)
        ).with_context(
          current_organization: current_organization,
          current_component: commentable.component
        )
        Decidim::Comments::CreateComment.call(form, current_user) do
          on(:ok) do |comment|
            handle_success(comment)
            render :create
          end

          on(:invalid) do
            @error = t("create.error", scope: "decidim.comments.comments")
            render :error
          end
        end
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
            commentable.root_commentable.comments.count
          else
            commentable.comments.count
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
    end
  end
end
