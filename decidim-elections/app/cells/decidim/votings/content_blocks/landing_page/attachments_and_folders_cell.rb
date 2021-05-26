# frozen_string_literal: true

module Decidim
  module Votings
    module ContentBlocks
      module LandingPage
        class AttachmentsAndFoldersCell < Decidim::ViewModel
          include Cell::ViewModel::Partial
          include Decidim::IconHelper
          include ActiveSupport::NumberHelper
          include Decidim::AttachmentsHelper

          delegate :current_participatory_space, to: :controller

          def show
            attachments_for(current_participatory_space)
          end
        end
      end
    end
  end
end
