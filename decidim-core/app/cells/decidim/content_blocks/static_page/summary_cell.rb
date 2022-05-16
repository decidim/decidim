# frozen_string_literal: true

module Decidim
  module ContentBlocks
    module StaticPage
      class SummaryCell < Decidim::ViewModel
        def content
          translated_attribute(model.settings.summary).html_safe
        end
      end
    end
  end
end
