# frozen_string_literal: true

module Decidim
  module Comments
    # Controller that manages the comments for a commentable object.
    #
    class CommentsController < Decidim::Comments::ApplicationController
      before_action :authenticate_user!
      before_action :set_commentable

      def create
        raise ActionController::RoutingError, "Not Found" unless commentable

        form = Decidim::Comments::CommentForm.from_params(params).with_context(
          current_organization: current_organization,
          current_component: commentable.component
        )
        Decidim::Comments::CreateComment.call(form, current_user) do
          on(:ok) do |comment|
            @comment = comment
            render :create
          end

          on(:invalid) do
            @error = t("create.error", scope: "decidim.comments.comments")
            render :error
          end
        end
      end

      private

      attr_reader :commentable

      def set_commentable
        @commentable = GlobalID::Locator.locate_signed(commentable_gid)
      end

      def commentable_gid
        params.require(:comment).fetch(:commentable_gid)
      end
    end
  end
end
