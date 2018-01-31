# frozen_string_literal: true

module Decidim
  module Accountability
    module AdminLog
      # This class holds the logic to render a `Decidim::Accountability::Result`
      # for the `AdminLog` log. See `Decidim::ActionLog#render_log` for
      # more info on the log types and renderers.
      #
      # Usage should be automatic and you shouldn't need to call this class
      # directly, but here's an example:
      #
      #    action_log = Decidim::ActionLog.last
      #    view_helpers # => this comes from the views
      #    ResultPresenter.new(action_log, view_helpers).render
      class ResultPresenter
        # Initializes the renderer.
        #
        # action_log - An instance of Decidim::ActionLog.last
        # view_helpers - An object holding the view helpers at the render time.
        #   Most probably should come automatically from the views.
        def initialize(action_log, view_helpers)
          @action_log = action_log
          @view_helpers = view_helpers
        end

        # Renders the resource associated to the given `action_log`.
        #
        # action_log - An instance of Decidim::ActionLog.last
        # view_helpers - An object holding the view helpers at the render time.
        #   Most probably should come automatically from the views.
        def render
          h.content_tag(:li) do
            [
              action_log.extra["user"]["name"],
              " (@",
              action_log.extra["user"]["nickname"],
              ")",
              " ",
              action_log.action,
              " ",
              action_log.extra["resource"]["title"]["ca"],
              " (",
              action_log.resource_type,
              " ",
              action_log.resource_id,
              ")"
            ].join("")
          end
        end

        private

        attr_reader :action_log, :view_helpers
        alias h view_helpers
      end
    end
  end
end
