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

    def resource_image_path
      nil
    end

    def has_image?
      false
    end

    def has_link_to_resource?
      true
    end

    def has_label?
      context[:label].presence
    end

    def label
      return if [false, "false"].include? context[:label]
      return @label ||= t(model.class.model_name.i18n_key, scope: "activerecord.models", count: 1) if [true, "true"].include? context[:label]
      context[:label]
    end

    def title
      translated_attribute model.title
    end

    def description
      attribute = model.try(:short_description) || model.try(:body) || model.description
      text = translated_attribute(attribute)

      decidim_sanitize(html_truncate(text, length: 100))
    end

    def has_authors?
      model.is_a?(Decidim::Authorable) || model.is_a?(Decidim::Coauthorable)
    end

    def has_actions?
      true
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

    def base_card_class
      "card--#{dom_class(model)}"
    end

    def card_classes
      classes = [base_card_class]
      return classes unless has_state?
      classes.concat(state_classes).join(" ")
    end

    def badge_classes
      state_classes.concat(["card__text--status"]).join(" ")
    end

    def state_classes
      ["muted"]
    end

    def comments_count
      model.comments.count
    end

    def statuses
      collection = [:creation_date]
      collection << :follow if model.is_a?(Decidim::Followable) && model != try(:current_user)
      collection << :comments_count if model.is_a?(Decidim::Comments::Commentable)
      collection
    end

    def creation_date_status
      l(model.created_at.to_date, format: :decidim_short)
    end

    def follow_status
      cell "decidim/follow_button", model, inline: true
    end

    def comments_count_status
      return render_comments_count unless has_link_to_resource?

      link_to resource_path do
        render_comments_count
      end
    end

    def render_comments_count
      with_tooltip t("decidim.comments.comments") do
        render :comments_counter
      end
    end

    def render_authorship
      cell("decidim/coauthorships", model, extra_small: true, has_actions: has_actions?)
    end
  end
end
