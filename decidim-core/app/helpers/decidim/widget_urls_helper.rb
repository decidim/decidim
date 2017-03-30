# frozen_string_literal: true
module Decidim
  module WidgetUrlsHelper
    def embedded_code_for(url)
      "<iframe src='#{url}'></iframe>"
    end
  end
end
