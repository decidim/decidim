# frozen_string_literal: true

module Decidim
  # Exposes the `Likes` so that users can like resources.
  class LikesController < Decidim::Components::BaseController
    # we need to +include+ to be able to call :like_button from the view
    include Decidim::LikeableHelper
    helper_method :like_button
    # we need to declare with +helper+ to be able to call :render_like_identity from the views
    helper Decidim::LikeableHelper
    helper_method :resource

    before_action :authenticate_user!

    def create
      enforce_permission_to(:create, :like, resource:)

      LikeResource.call(resource, current_user) do
        on(:ok) do
          resource.reload
          render :update_buttons_and_counters
        end

        on(:invalid) do
          render json: { error: I18n.t("resource_likes.create.error", scope: "decidim") }, status: :unprocessable_entity
        end
      end
    end

    def destroy
      enforce_permission_to(:withdraw, :like, resource:)

      UnlikeResource.call(resource, current_user) do
        on(:ok) do
          resource.reload
          render :update_buttons_and_counters
        end
      end
    end

    # should be pubic in order to be visible in NeedsPermission#permissions_context
    def current_component
      resource.component
    end

    private

    def resource
      gid_param = params[:id] || params[:resource_id]
      @resource ||= GlobalID::Locator.locate(GlobalID.parse(gid_param))
    end

    def current_participatory_space
      current_component.participatory_space
    end
  end
end
