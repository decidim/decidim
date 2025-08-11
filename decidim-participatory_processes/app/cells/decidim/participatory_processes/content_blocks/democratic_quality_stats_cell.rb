# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module ContentBlocks
      class DemocraticQualityStatsCell < Decidim::ContentBlocks::BaseCell
        include ParticipatorySpaceContentBlocksHelper

        private

        def stats
          @stats ||= presenter.stats
        end

        def finished_survey?
          @finished_survey ||= presenter.finished_survey?
        end

        def presenter
          @presenter ||= ParticipatoryProcessDemocraticQualityStatsPresenter.new(model, resource)
        end

        def info_url
          decidim.page_path("democratic-quality-indicators")
        end
      end
    end
  end
end
