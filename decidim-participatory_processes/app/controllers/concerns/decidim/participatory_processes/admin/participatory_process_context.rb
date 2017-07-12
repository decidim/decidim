# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # This module, when injected into a controller, ensures there's a
      # Participatory Process available and deducts it from the context.
      module ParticipatoryProcessContext
        def self.extended(base)
          base.class_eval do
            include Concerns::ParticipatoryProcessAdmin

            delegate :active_step, to: :current_participatory_process, prefix: false

            alias_method :current_participatory_process, :current_featurable
          end
        end
      end
    end
  end
end
