# frozen_string_literal: true

module Decidim
  module ContentBlocks
    class HeroSettingsFormCell < Decidim::ViewModel
      alias settings_fields model

      def content_block
        options[:content_block]
      end
    end
  end
end
