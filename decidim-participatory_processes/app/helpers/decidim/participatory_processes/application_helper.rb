# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # Custom helpers, scoped to the participatory processes engine.
    #
    module ApplicationHelper
      include Decidim::ResourceHelper

      # Public: Renders all hooks registered as `hook_name`.
      #
      # hook_name - a Symbol representing the name of the hook.
      #
      # Returns an HTML safe String.
      def render_participatory_processes_hook(hook_name)
        Decidim::ParticipatoryProcesses.view_hooks.render(hook_name, self)
      end
    end
  end
end
