# frozen_string_literal: true

module Decidim
  module Admin
    # Helpers to render log entries.
    #
    module LogRenderHelper
      # Renders the given `action_log`. See `Decidim::Loggable` for
      # more info on how log presenters work.
      #
      # action_log - An instance of `ActionLog`
      # log_type - A symbol representing the log type
      #
      # Returns an HTML-safe String.
      def render_log(action_log, log_type = :admin_log)
        presenter_klass = action_log.log_presenter_class_for(log_type)
        presenter_klass.new(action_log, self).present
      end
    end
  end
end
