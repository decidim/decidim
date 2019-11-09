# frozen_string_literal: true

module Decidim
  # This cell renders the button to follow the given resource.
  class FollowButtonCell < Decidim::ViewModel
    include LayoutHelper

    def show
      return if model == current_user

      render
    end

    private

    def button_classes
      return "card__button secondary text-uppercase follow-button mb-none" if inline?
      return "button secondary hollow expanded button--icon button--sc" if large?

      "button secondary hollow expanded small button--icon follow-button"
    end

    def icon_options
      return { class: "icon--small" } if inline?

      {}
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

    def decidim
      Decidim::Core::Engine.routes.url_helpers
    end
  end
end
