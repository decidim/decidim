# frozen_string_literal: true
module Decidim
  # View helpers related to the layout.
  module LayoutHelper
    include Decidim::FlashMessagesHelper

    def decidim_page_title
      Decidim.config.application_name
    end
  end
end
