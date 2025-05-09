# frozen_string_literal: true

module Decidim
  # This cell renders the like button and the likes count.
  # It only supports one row of buttons per page due to current tag ids used by javascript.
  class LikeButtonsCell < Decidim::ViewModel
    include CellsHelper
    include LikeableHelper
    include ResourceHelper

    # Renders the "Like" button.
    # Contains all the logic about how the button should be rendered
    # and which actions the button must trigger.
    #
    # It takes into account:
    # - if likes are enabled
    # - if users are logged in
    # - if users require verification
    def show
      return render :disabled_likes if likes_blocked?
      return render unless current_user
      return render :disabled_likes if user_can_not_participate?
      return render :verification_modal unless like_allowed?

      render
    end

    def button_classes
      "button button__sm button__transparent-secondary"
    end

    # The resource being un/liked is the Cell's model.
    def resource
      model
    end

    # produce the path to likes from the engine routes as the cell does not have access to routes
    def likes_path(*)
      decidim.likes_path(*)
    end

    # produce the path to an like from the engine routes as the cell does not have access to routes
    def like_path(*)
      decidim.like_path(*)
    end

    def button_content
      render
    end

    private

    def likes_blocked?
      current_settings.likes_blocked?
    end

    def user_can_not_participate?
      !current_component.participatory_space.can_participate?(current_user)
    end

    def like_allowed?
      allowed_to?(:create, :like, resource:)
    end

    def like_translated
      @like_translated ||= resource.liked_by?(current_user) ? t("decidim.like_buttons_cell.already_liked") : t("decidim.like_buttons_cell.like")
    end

    def like_icon
      @like_icon ||= resource_type_icon(resource.liked_by?(current_user) ? "dislike" : "like")
    end

    def raw_model
      model.try(:__getobj__) || model
    end
  end
end
