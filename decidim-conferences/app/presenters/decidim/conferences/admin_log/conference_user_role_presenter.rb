# frozen_string_literal: true

module Decidim
  module Conferences
    module AdminLog
      # This class holds the logic to present a `Decidim::ConferenceUserRole`
      # for the `AdminLog` log.
      #
      # Usage should be automatic and you shouldn't need to call this class
      # directly, but here's an example:
      #
      #    action_log = Decidim::ActionLog.last
      #    view_helpers # => this comes from the views
      #    ConferenceUserRolePresenter.new(action_log, view_helpers).present
      class ConferenceUserRolePresenter < Decidim::Log::BasePresenter
        private

        def diff_fields_mapping
          {
            role: "Decidim::Conferences::AdminLog::ValueTypes::RolePresenter"
          }
        end

        def i18n_labels_scope
          "activemodel.attributes.conference_user_role"
        end

        def action_string
          case action
          when "create", "delete", "update"
            "decidim.admin_log.conference_user_role.#{action}"
          else
            super
          end
        end

        def changeset
          return super unless action.to_s == "delete"

          Decidim::Log::DiffChangesetCalculator.new(
            { role: [action_log.version.object["role"], ""] },
            diff_fields_mapping,
            i18n_labels_scope
          ).changeset
        end

        def diff_actions
          super + %w(delete)
        end
      end
    end
  end
end
