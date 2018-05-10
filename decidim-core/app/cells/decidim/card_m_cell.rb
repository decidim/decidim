# frozen_string_literal: true

module Decidim
  # This cell is used a based for all M-sized cards. It holds the basic layout
  # so other cells only have to customize a few methods or overwrite views.
  class CardMCell < Decidim::ViewModel
    include Cell::ViewModel::Partial
    include Decidim::ApplicationHelper
    include Decidim::TooltipHelper
    include Decidim::SanitizeHelper
    include Decidim::CardHelper
    include Decidim::LayoutHelper

    def show
      render
    end

    private

    def resource_path
      resource_locator(model).path
    end

    def title
      translated_attribute model.title
    end

    def description
      decidim_sanitize(translated_attribute(model.description))
    end

    def decidim
      Decidim::Core::Engine.routes.url_helpers
    end

    def has_author?
      model.is_a?(Decidim::Authorable)
    end

    def has_state?
      false
    end

    def has_badge?
      has_state?
    end

    def badge_name
      model.state
    end

    def card_classes
      classes = ["card--#{dom_class(model)}"]
      return classes unless has_state?
      classes.concat(state_classes).join(" ")
    end

    def badge_classes
      state_classes.concat(["card__text--status"]).join(" ")
    end

    def comments_count
      model.comments.count
    end

    def statuses
      [:creation_date, :follow, :comments_count]
    end

    def creation_date_status
      l(model.created_at.to_date, format: :decidim_short)
    end

    def follow_status
      cell "decidim/follow_button", model, inline: true
    end

    def comments_count_status
      link_to resource_path do
        with_tooltip t("decidim.comments.comments") do
          render :comments_counter
        end
      end
    end
  end
end
