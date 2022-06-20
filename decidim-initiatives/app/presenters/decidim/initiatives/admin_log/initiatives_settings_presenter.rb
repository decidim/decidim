# frozen_string_literal: true

module Decidim
  module Initiatives
    module AdminLog
      # This class holds the logic to present a `Decidim::InitiativesSettings`
      # for the `AdminLog` log.
      #
      # Usage should be automatic and you shouldn't need to call this class
      # directly, but here's an example:
      #
      #    action_log = Decidim::ActionLog.last
      #    view_helpers # => this comes from the views
      #    InitiativesSettingsPresenter.new(action_log, view_helpers).present
      class InitiativesSettingsPresenter < Decidim::Log::BasePresenter
        private

        def action_string
          case action
          when "update"
            "decidim.initiatives.admin_log.initiatives_settings.#{action}"
          end
        end
      end
    end
  end
end
