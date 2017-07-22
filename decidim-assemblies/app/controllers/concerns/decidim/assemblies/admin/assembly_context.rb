# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # This module, when injected into a controller, ensures there's a
      # Assembly available and deducts it from the context.
      module AssemblyContext
        def self.extended(base)
          base.class_eval do
            include Concerns::AssemblyAdmin

            delegate :active_step, to: :current_assembly, prefix: false

            alias_method :current_assembly, :current_participatory_space
          end
        end
      end
    end
  end
end
