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
        end
      end
    end
  end
end
