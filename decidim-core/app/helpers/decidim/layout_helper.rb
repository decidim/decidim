# frozen_string_literal: true
module Decidim
  # View helpers related to the layout.
  module LayoutHelper
    def decidim_page_title
      Decidim.config.application_name
    end
  end
end
