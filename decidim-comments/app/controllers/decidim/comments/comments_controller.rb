# frozen_string_literal: true

module Decidim
  module Comments
    # Controller that manages the comments for a commentable object.
    #
    class CommentsController < Decidim::Comments::ApplicationController
      before_action :authenticate_user!
      before_action :set_commentable

      helper_method :root_depth, :reply?

      def create
        raise ActionController::RoutingError, "Not Found" unless commentable

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

      def handle_success(comment)
        @comment = comment
      end

      def commentable_gid
        params.require(:comment).fetch(:commentable_gid)
      end

      def reply?
        comment.root_commentable != commentable
      end

      def root_depth
        params.fetch(:root_depth, 0).to_i
      end
    end
  end
end
