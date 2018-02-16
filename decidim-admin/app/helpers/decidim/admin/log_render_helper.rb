# frozen_string_literal: true

module Decidim
  module Admin
    # Helpers to render log entries.
    #
    module LogRenderHelper
      # Renders the given `log_entry`. See `Decidim::ActionLog#render_log` for
      # more info on the log renderers, and how to implement your own.
      #
      # log_entry - An instance of `ActionLog`
      #
      # Returns an HTML-safe String.
      def render_log(log_entry)
        log_entry.render_log(self)
      end
    end
  end
end
