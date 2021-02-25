# frozen_string_literal: true

module Decidim
  module Votings
    module ContentBlocks
      module LandingPage
        class DescriptionCell < Decidim::ViewModel
          delegate :current_participatory_space, to: :controller

          def show
            content_tag(:div, cell_content, class: "row column")
          end

          def cell_content
            translated_attribute(current_participatory_space.description)
          end
        end
      end
    end
  end
end
