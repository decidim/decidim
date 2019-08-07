# frozen_string_literal: true

module Decidim
  module WidgetUrlsHelper
    def embed_modal_for(url)
      js_embed_code = String.new(content_tag(:script, "", src: url))
      embed_code = String.new(content_tag(:noscript, content_tag(:iframe, "", src: url.gsub(".js", ".html"), frameborder: 0, scrolling: "vertical")))
      render partial: "decidim/shared/embed_modal", locals: { js_embed_code: js_embed_code, embed_code: embed_code }
    end
  end
end
