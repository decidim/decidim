# frozen_string_literal: true

module Decidim
  module AdminLog
    # This class holds the logic to present a `Decidim::AreaType`
    # for the `AdminLog` log.
    #
    # Usage should be automatic and you shouldn't need to call this class
    # directly, but here's an example:
    #
    #    action_log = Decidim::ActionLog.last
    #    view_helpers # => this comes from the views
    #    AreaTypePresenter.new(action_log, view_helpers).present
    class AreaTypePresenter < Decidim::Log::BasePresenter
      private

      def diff_fields_mapping
        {
          name: :i18n,
          plural: :i18n
        }
      end

      def action_string
        case action
        when "create", "delete", "update"
          "decidim.admin_log.area_type.#{action}"
        else
          super
        end
      end
    end
  end
end
