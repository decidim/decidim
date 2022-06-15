# frozen_string_literal: true

module Decidim
  module AdminLog
    # This class holds the logic to present a `Decidim::ContextualHelpSection`
    # for the `AdminLog` log.
    #
    # Usage should be automatic and you shouldn't need to call this class
    # directly, but here's an example:
    #
    #    action_log = Decidim::ActionLog.last
    #    view_helpers # => this comes from the views
    #    ContextualHelpSectionPresenter.new(action_log, view_helpers).present
    class ContextualHelpSectionPresenter < Decidim::Log::BasePresenter
      private

      def diff_fields_mapping
        {
          content: :i18n
        }
      end

      def action_string
        case action
        when "update"
          "decidim.admin_log.contextual_help_section.#{action}"
        else
          super
        end
      end
    end
  end
end
