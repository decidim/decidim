# frozen_string_literal: true

module Decidim
  module Elections
    module AdminLog
      # This class holds the logic to present a `Decidim::Elections::Election`
      # for the `AdminLog` log.
      #
      # Usage should be automatic and you should not need to call this class
      # directly, but here is an example:
      #
      #    action_log = Decidim::ActionLog.last
      #    view_helpers # => this comes from the views
      #    ElectionPresenter.new(action_log, view_helpers).present
      class ElectionPresenter < Decidim::Log::BasePresenter
        private

        def action_string
          case action
          when "create", "update", "soft_delete", "restore", "publish", "unpublish"
            "decidim.elections.admin_log.election.#{action}"
          else
            super
          end
        end

        def diff_fields_mapping
          {
            title: :i18n,
            description: :i18n,
            start_at: :date,
            end_at: :date,
            published_at: :date
          }
        end
      end
    end
  end
end
