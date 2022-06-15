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

    # deprecated
    def followers_count
      if model.respond_to?(:followers_count)
        model.followers_count
      else
        model.followers.count
      end
    end

    def button_classes
      "button text-secondary white sm whitespace-nowrap"
    end

    # deprecated
    def icon_options
      icon_base_options = { aria_hidden: true }
      return icon_base_options.merge(class: "icon--small", role: "img", "aria-hidden": true) if inline?

      icon_base_options
    end

    # deprecated
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
      return false unless current_user

      current_user.follows?(model)
    end

    def decidim
      Decidim::Core::Engine.routes.url_helpers
    end
  end
end
