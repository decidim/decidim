# frozen_string_literal: true

module Decidim
  module ContentBlocks
    module StaticPage
      class SectionCell < Decidim::ViewModel
        def content
          decidim_sanitize_editor_admin(translated_attribute(model.settings.content))
        end
      end
    end
  end
end
