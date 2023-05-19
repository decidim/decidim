# frozen_string_literal: true

module Decidim
  module ContentBlocks
    class RedesignedHtmlCell < Decidim::ViewModel
      def block_id
        "html-block-#{model.manifest_name.parameterize.gsub("_", "-")}"
      end

      def html_content
        translated_attribute(model.settings.html_content).html_safe
      end
    end
  end
end
