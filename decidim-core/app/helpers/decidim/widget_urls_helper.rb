# frozen_string_literal: true
module Decidim
  module WidgetUrlsHelper
    def embedded_code_for(url)
      "<iframe id='decidim-iframe' frameborder='0' scrolling='no' onload='setIframeHeight(this.id)' src='#{url}'></iframe>".html_safe
    end
  end
end
