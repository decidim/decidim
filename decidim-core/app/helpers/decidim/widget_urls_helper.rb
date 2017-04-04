# frozen_string_literal: true
module Decidim
  module WidgetUrlsHelper
    def embedded_code_for(url)
      "#{content_tag(:iframe, '', src: url, id: "decidim-iframe", frameborder: 0, scrolling: "no", onload: "setIframeHeight(this.id)")}"
    end
  end
end
