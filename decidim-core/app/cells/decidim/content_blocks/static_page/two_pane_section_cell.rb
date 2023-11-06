# frozen_string_literal: true

module Decidim
  module ContentBlocks
    module StaticPage
      class TwoPaneSectionCell < Decidim::ViewModel
        def left_column
          translated_attribute(model.settings.left_column).html_safe
        end

        def right_column
          translated_attribute(model.settings.right_column).html_safe
        end
      end
    end
  end
end
