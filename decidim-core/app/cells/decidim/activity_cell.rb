# frozen_string_literal: true

module Decidim
  class ActivityCell < Decidim::ViewModel
    include Cell::ViewModel::Partial
    include Decidim::IconHelper

    private

    def title
      translated_attribute(model.title)
    end

    def activity_link_path
      resource_locator(model).path
    end

    def activity_link_text
      translated_attribute(model.title)
    end
  end
end
