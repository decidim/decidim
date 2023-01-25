# frozen_string_literal: true

module Decidim
  module ContentBlocks
    module StaticPage
      class SectionCell < Decidim::ViewModel
        def content
          translated_attribute(model.settings.content).html_safe
        end
      end
    end
  end
end
