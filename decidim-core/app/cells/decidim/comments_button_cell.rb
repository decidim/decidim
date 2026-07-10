# frozen_string_literal: true

module Decidim
  class CommentsButtonCell < ButtonCell
    include UserRoleChecker

    def show
      if options.has_key?(:display)
        return render if options[:display]

        return
      end

      render if comments_enabled?
    end

    private

    def comments_enabled?
      return true if user_has_any_role?(current_user, current_participatory_space)

      component_settings.comments_enabled? && !current_settings.try(:comments_blocked?)
    end

    def path
      return "#add-comment-anchor" if current_user

      nil
    end

    def text
      t("decidim.comments.comments_title")
    end

    def icon_name
      resource_type_icon_key "Decidim::Comments::Comment"
    end

    def button_classes
      "button button__sm button__transparent-secondary add-comment-mobile"
    end

    def html_options
      return {} if current_user

      { data: { "dialog-open": "loginModal" } }
    end
  end
end
