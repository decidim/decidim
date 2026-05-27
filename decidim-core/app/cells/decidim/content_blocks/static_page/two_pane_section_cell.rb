# frozen_string_literal: true

module Decidim
  module ContentBlocks
    module StaticPage
      class TwoPaneSectionCell < Decidim::ViewModel
        def left_column
          decidim_sanitize_editor_admin(translated_attribute(model.settings.left_column))
        end

        def right_column
          decidim_sanitize_editor_admin(translated_attribute(model.settings.right_column))
        end
      end
    end
  end
end
