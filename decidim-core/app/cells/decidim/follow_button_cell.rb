# frozen_string_literal: true

module Decidim
  # This cell renders the button to follow the given resource.
  class FollowButtonCell < Decidim::ViewModel
    include LayoutHelper
    include Decidim::SanitizeHelper
    include Decidim::ResourceHelper

    def show
      return if model == current_user

      render
    end

    private

    def button_classes
      return "card__button follow-button mb-none" if inline?

      extra_classes = ""
      extra_classes += " active" if current_user_follows?
      extra_classes += begin
        if large?
          " button--sc"
        else
          " small"
        end
      end

      "button expanded button--icon follow-button #{extra_classes}"
    end

    def icon_options
      return { class: "icon--small", role: "img" } if inline?

      {}
    end

    def render_screen_reader_title_for(resource)
      content_tag :span, class: "show-for-sr" do
        decidim_html_escape(resource_title(resource))
      end
    end

    # Checks whether the button will be shown inline or not. Inline buttons will
    # not have any border, and the icon will be small. This is mostly intended
    # to be used from cards.
    def inline?
      options[:inline]
    end

    # Checks whether the button will be shown large or not.
    def large?
      options[:large]
    end

    def current_user_follows?
      current_user.follows?(model)
    end

    def decidim
      Decidim::Core::Engine.routes.url_helpers
    end
  end
end
