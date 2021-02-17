# frozen_string_literal: true

module Decidim
  module Votings
    module ContentBlocks
      module LandingPage
        class AttachmentsAndFoldersCell < Decidim::ViewModel
          def show
            content_tag(:div, "AttachmentsAndFoldersCell")
          end
        end
      end
    end
  end
end
