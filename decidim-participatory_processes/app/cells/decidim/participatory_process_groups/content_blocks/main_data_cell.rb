# frozen_string_literal: true

module Decidim
  module ParticipatoryProcessGroups
    module ContentBlocks
      class MainDataCell < Decidim::ContentBlocks::ParticipatorySpaceMainDataCell
        include Decidim::SanitizeHelper

        delegate :title, :description, to: :resource

        private

        def title_text
          translated_attribute(title)
        end

        def description_text
          decidim_sanitize_editor_admin translated_attribute(description)
        end
      end
    end
  end
end
