# frozen_string_literal: true

module Decidim
  module Votings
    module ContentBlocks
      class MainDataCell < Decidim::ContentBlocks::ParticipatorySpaceMainDataCell
        include VotingsHelper
        include Decidim::ComponentPathHelper
        include Decidim::SanitizeHelper
        include ActiveLinkTo

        delegate :current_participatory_space, to: :controller

        private

        def title_text
          t("title", scope: "decidim.participatory_processes.participatory_processes.show")
        end

        def description_text
          decidim_sanitize_editor_admin translated_attribute(current_participatory_space.description)
        end

        def nav_items
          voting_nav_items(current_participatory_space)
        end

        def decidim_votings
          Decidim::Votings::Engine.routes.url_helpers
        end
      end
    end
  end
end
