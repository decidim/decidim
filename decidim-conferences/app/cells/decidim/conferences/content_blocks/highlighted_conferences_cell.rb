# frozen_string_literal: true

module Decidim
  module Conferences
    module ContentBlocks
      class HighlightedConferencesCell < Decidim::ContentBlocks::HighlightedParticipatorySpacesCell
        BLOCK_ID = "highlighted-conferences"

        delegate :current_user, to: :controller

        def highlighted_spaces
          OrganizationPrioritizedConferences.new(current_organization, current_user)
        end

        def i18n_scope
          "decidim.conferences.pages.home.highlighted_conferences"
        end

        def all_path
          Decidim::Conferences::Engine.routes.url_helpers.conferences_path
        end

        private

        def block_id = BLOCK_ID
      end
    end
  end
end
