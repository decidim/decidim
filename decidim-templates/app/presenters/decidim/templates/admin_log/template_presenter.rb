# frozen_string_literal: true

module Decidim
  module Templates
    module AdminLog
      # This class holds the logic to present a `Decidim::Template`
      # for the `AdminLog` log.
      #
      # Usage should be automatic and you shouldn't need to call this class
      # directly, but here's an example:
      #
      #    action_log = Decidim::ActionLog.last
      #    view_helpers # => this comes from the views
      #    TemplatePresenter.new(action_log, view_helpers).present
      class TemplatePresenter < Decidim::Log::BasePresenter
        private

        def diff_fields_mapping
          {
            name: :i18n,
            description: :i18n
          }
        end

        def action_string
          case action
          when "create", "update", "delete", "duplicate"
            "decidim.templates.admin_log.template.#{action}"
          else
            super
          end
        end
      end
    end
  end
end
