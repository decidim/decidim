# frozen_string_literal: true

module Decidim
  module Votings
    module ContentBlocks
      module LandingPage
        class TimelineCell < Decidim::ViewModel
          private

          def html_content
            translated_attribute(model.settings.html_content).html_safe
          end
        end
      end
    end
  end
end
