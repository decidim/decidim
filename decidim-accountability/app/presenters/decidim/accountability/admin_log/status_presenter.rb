# frozen_string_literal: true

module Decidim
  module Accountability
    module AdminLog
      # This class holds the logic to present a `Decidim::Accountability::Status`
      # for the `AdminLog` log.
      #
      # Usage should be automatic and you shouldn't need to call this class
      # directly, but here's an example:
      #
      #    action_log = Decidim::ActionLog.last
      #    view_helpers # => this comes from the views
      #    StatusPresenter.new(action_log, view_helpers).present
      class StatusPresenter < Decidim::Log::BasePresenter
        private

        def action_string
          case action
          when "create", "delete", "update"
            "decidim.accountability.admin_log.status.#{action}"
          else
            super
          end
        end

        def diff_fields_mapping
          {
            key: :string,
            name: :i18n,
            description: :i18n,
            progress: :integer
          }
        end
      end
    end
  end
end
