# frozen_string_literal: true

module Decidim
  module Votings
    module ContentBlocks
      module LandingPage
        class DescriptionCell < Decidim::ViewModel
          include Decidim::SanitizeHelper

          delegate :current_participatory_space, to: :controller

          private

          def introductory_image
            current_participatory_space.attached_uploader(:introductory_image)
          end

          def description_text
            decidim_sanitize_editor(translated_attribute(current_participatory_space.description))
          end

          def button_show_more_text
            t(:show_more, scope: "decidim.votings.content_blocks.landing_page.description")
          end

          def button_show_less_text
            t(:show_less, scope: "decidim.votings.content_blocks.landing_page.description")
          end
        end
      end
    end
  end
end
