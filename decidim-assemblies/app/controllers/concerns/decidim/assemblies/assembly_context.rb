# frozen_string_literal: true

module Decidim
  module Assemblies
    # This module, when injected into a controller, ensures there's a
    # Assembly available and deducts it from the context.
    module AssemblyContext
      def self.extended(base)
        base.class_eval do
          include NeedsAssembly

          layout "layouts/decidim/assembly"

          before_action do
            authorize! :read, current_assembly
          end
        end
      end

      def ability_context
        super.merge(current_assembly: current_assembly)
      end
    end
  end
end
