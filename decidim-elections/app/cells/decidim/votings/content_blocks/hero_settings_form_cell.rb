# frozen_string_literal: true

module Decidim
  module Votings
    module ContentBlocks
      class HeroSettingsFormCell < Decidim::ViewModel
        alias form model

        def content_block
          options[:content_block]
        end
      end
    end
  end
end
