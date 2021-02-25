# frozen_string_literal: true

module Decidim
  module Votings
    module ContentBlocks
      module LandingPage
        class HeaderCell < Decidim::ViewModel
          delegate :current_participatory_space, to: :controller

          def show
            content_tag(:div, cell_content)
          end

          def cell_content
            translated_attribute(current_participatory_space.title)
          end
        end
      end
    end
  end
end
