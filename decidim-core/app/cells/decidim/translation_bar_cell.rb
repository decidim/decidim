# frozen_string_literal: true

module Decidim
  # This cell is used to render a button to toggle machine translations. It will
  # only render if the translations are enabled.
  class TranslationBarCell < Decidim::ViewModel
    include Decidim::TranslatableAttributes

    def show
      return unless renderable?

      render
    end

    def renderable?
      Decidim.config.enable_machine_translations &&
        model.enable_machine_translations
    end

    def link
      original_url = request.original_url
      parsed_url = URI.parse(original_url)
      query = parsed_url.query
      new_query_params = "toggle_translations=true"

      new_query = if RequestStore.store[:toggle_machine_translations]
                    query.gsub("toggle_translations=true", "")
                  elsif query.nil?
                    new_query_params
                  else
                    "#{query}&#{new_query_params}"
                  end

      parsed_url.query = new_query
      url = parsed_url.to_s

      link_to button_text, url, class: "button small hollow"
    end

    def button_text
      if must_render_translation?(model)
        t("decidim.translation_bar.show_original")
      else
        t("decidim.translation_bar.show_translated")
      end
    end

    def help_text
      t("decidim.translation_bar.help_text")
    end
  end
end
