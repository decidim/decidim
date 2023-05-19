# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module ContentBlocks
      class MainDataCell < Decidim::ContentBlocks::ParticipatorySpaceMainDataCell
        include ParticipatorySpaceContentBlocksHelper
        include ParticipatoryProcessHelper
        include Decidim::ComponentPathHelper
        include ActiveLinkTo

        delegate :short_description, :description, to: :resource

        private

        def title_text
          t("title", scope: "decidim.participatory_processes.participatory_processes.show")
        end

        def short_description_text
          decidim_sanitize_editor_admin translated_attribute(short_description)
        end

        def description_text
          decidim_sanitize_editor_admin translated_attribute(description)
        end

        def details_path
          decidim_participatory_processes.description_participatory_process_path(resource)
        end

        def nav_items
          process_nav_items(resource)
        end
      end
    end
  end
end
