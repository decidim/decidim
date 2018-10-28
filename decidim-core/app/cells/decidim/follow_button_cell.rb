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

    def current_user
      context[:current_user]
    end

    def button_classes
      return "card__button secondary text-uppercase follow-button mb-none" if inline?
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
  end
end
