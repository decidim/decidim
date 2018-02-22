# frozen_string_literal: true

module Decidim
  module AdminLog
    # This class holds the logic to present a `Decidim::ParticipatoryProcessUserRole`
    # for the `AdminLog` log.
    #
    # Usage should be automatic and you shouldn't need to call this class
    # directly, but here's an example:
    #
    #    action_log = Decidim::ActionLog.last
    #    view_helpers # => this comes from the views
    #    ParticipatoryProcessUserRolePresenter.new(action_log, view_helpers).present
    class ParticipatoryProcessUserRolePresenter < Decidim::Log::BasePresenter
      private

      def diff_fields_mapping
        {
          role: "Decidim::ParticipatoryProcesses::AdminLog::ValueTypes::RolePresenter"
        }
      end

      def action_string
        case action
        when "create"
          "decidim.admin_log.participatory_process_user_role.#{action}"
        else
          super
        end
      end

      def i18n_labels_scope
        "activemodel.attributes.participatory_process_user_role"
      end
    end
  end
end
