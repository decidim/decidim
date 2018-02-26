# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # Custom helpers, scoped to the participatory processes engine.
    #
    module ApplicationHelper
      include Decidim::ResourceHelper

      # Public: Renders all hooks registered as `hook_name`.
      #
      #   Note: We're passing a deep copy of the view context to allow
      #   us to extend it without polluting the original view context
      #
      # @param hook_name [Symbol] representing the name of the hook.
      #
      # @return [String] an HTML safe String
      def render_participatory_processes_hook(hook_name)
        Decidim::ParticipatoryProcesses.view_hooks.render(hook_name, deep_dup)
      end
    end
  end
end
