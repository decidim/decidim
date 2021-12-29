# frozen_string_literal: true

module Decidim
  module Votings
    module AdminLog
      # This class holds the logic to present a `Decidim::Votings::Voting`
      # for the `AdminLog` log.
      #
      # Usage should be automatic and you shouldn't need to call this class
      # directly, but here's an example:
      #
      #    action_log = Decidim::ActionLog.last
      #    view_helpers # => this comes from the views
      #    MonitoringCommitteeMemberPresenter.new(action_log, view_helpers).present
      class MonitoringCommitteeMemberPresenter < Decidim::Log::BasePresenter
        private

        def monitoring_committee_member_user
          @monitoring_committee_member_user ||= action_log.resource&.user
        end

        def monitoring_committee_member_user_extra
          {
            "name" => monitoring_committee_member_user.name,
            "nickname" => monitoring_committee_member_user.nickname
          }
        end

        def monitoring_committee_member_user_presenter
          @monitoring_committee_member_user_presenter ||= Decidim::Log::UserPresenter.new(monitoring_committee_member_user, h, monitoring_committee_member_user_extra)
        end

        def i18n_params
          super.merge(
            monitoring_committee_member_user: monitoring_committee_member_user.present? ? monitoring_committee_member_user_presenter.present : resource_presenter.try(:present)
          )
        end

        def action_string
          case action
          when "create", "delete"
            "decidim.votings.admin_log.monitoring_committee_member.#{action}"
          else
            super
          end
        end
      end
    end
  end
end
