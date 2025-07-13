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

        def rich_text_processors?
          true
        end

        def short_description_text
          presenter.short_description
        end

        def description_text
          presenter.description
        end

        def nav_items
          process_nav_items(resource)
        end

        def presenter
          @presenter ||= Decidim::ParticipatoryProcesses::ParticipatoryProcessPresenter.new(resource)
        end
      end
    end
  end
end
