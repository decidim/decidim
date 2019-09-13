# frozen_string_literal: true

module Decidim
  # Helper that provides convenient methods to deal with translated attributes.
  module DeeplHelper
    include Decidim::TranslatableAttributes

    # Help to display the translation link, needs translate_title and
    # translate_body helper to indicate where to inject the translated data
    def translate_button_helper_for(title:, body:, model:, options: {})
      return unless translation_available?

      translate_link(title, body, model, options)
    end

    def translate_helper_for(element:, model:)
      return unless translation_available?

      "#{target_helper(model)}_#{element}"
    end

    def translate_link(title, body, model, options)
      style = options[:class] ? "card__translate #{options[:class]}" : "card__translate"

      content_tag(:div, class: style) do
        link_to "#", class: "translatable_btn btn btn-secondary", data: {
          title: title,
          body: body,
          targetElem: target_helper(model),
          targetlang: deepl_target_locale,
          translatable: true,
          translated: t("translated", scope: "decidim.translate"),
          original: t("original", scope: "decidim.translate")
        } do
          tooltip_content
        end
      end
    end

    def tooltip_content
      content = icon "globe", class: "action-icon action-icon--disabled"
      content << content_tag(:span, data: { tooltip: true, disable_hover: false, click_open: false }, title: t("tooltip", scope: "decidim.translate")) do
        link_content
      end
    end

    def link_content
      content = content_tag(:span, t("original", scope: "decidim.translate"))
      content << content_tag(:div, "", class: "loading-spinner loading-spinner--hidden")
    end

    def target_helper(model)
      "#{model.class.name.demodulize.downcase}_#{model.id}"
    end

    def translation_available?
      return unless current_organization

      current_organization.deepl_api_key.present? && current_organization.translatable_locales.count > 1
    end

    def deepl_target_locale
      return default_locale.upcase unless %w(EN DE FR ES PT IT NL PL RU).include? current_locale.upcase

      current_locale.upcase
    end
  end
end
