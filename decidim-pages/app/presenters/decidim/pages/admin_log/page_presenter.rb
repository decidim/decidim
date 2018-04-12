# frozen_string_literal: true

module Decidim
  module Pages
    module AdminLog
      # This class holds the logic to present a `Decidim::Page`
      # for the `AdminLog` log.
      #
      # Usage should be automatic and you shouldn't need to call this class
      # directly, but here's an example:
      #
      #    action_log = Decidim::ActionLog.last
      #    view_helpers # => this comes from the views
      #    PagePresenter.new(action_log, view_helpers).present
      class PagePresenter < Decidim::Log::BasePresenter
        private

        def diff_fields_mapping
          {
            body: :i18n
          }
        end

        def action_string
          case action
          when "update"
            "decidim.admin_log.page.#{action}"
          else
            super
          end
        end

        def i18n_labels_scope
          "decidim.pages.admin.models.components"
        end
      end
    end
  end
end
