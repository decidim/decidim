# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module ContentBlocks
      class HeroCell < Decidim::ContentBlocks::ParticipatorySpaceHeroCell
        include Decidim::ApplicationHelper

        delegate :active_step, to: :resource

        def decidim_participatory_processes
          Decidim::ParticipatoryProcesses::Engine.routes.url_helpers
        end

        def cta_text
          @cta_text ||= translated_attribute(active_step.cta_text).presence
        end

        def cta_path
          @cta_path ||= active_step.cta_path.presence && step_cta_url(resource)
        end
      end
    end
  end
end
