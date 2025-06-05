# frozen_string_literal: true

module Decidim
  # This cell renders the button to follow the given resource.
  class FollowButtonCell < Decidim::ButtonCell
    def show
      return if model == current_user

      render
    end

    def followers_count
      if model.respond_to?(:followers_count)
        model.followers_count
      else
        model.followers.size
      end
    end

    def id_option
      @id_option ||= options[:mobile] ? "follow-mobile" : "follow"
    end

    private

    # This method is required by action_authorized_button_to
    def current_component
      controller.try(:current_component)
    end

    def button_classes
      options[:button_classes] || "dropdown__button"
    end

    def text
      current_user_follows? ? t("decidim.follows.destroy.button") : t("decidim.follows.create.button")
    end

    def path
      decidim.follow_path(req_params)
    end

    def req_params
      { follow: { followable_gid: model.to_sgid.to_s, button_classes: } }
    end

    def method
      current_user_follows? ? :delete : :post
    end

    def icon_name
      current_user_follows? ? resource_type_icon_key("unfollow") : resource_type_icon_key("follow")
    end

    def remote
      true
    end

    def current_user_follows?
      return false unless current_user

      current_user.follows?(model)
    end

    def decidim
      Decidim::Core::Engine.routes.url_helpers
    end
  end
end
