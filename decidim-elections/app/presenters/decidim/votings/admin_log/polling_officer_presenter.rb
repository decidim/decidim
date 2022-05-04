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
      #    PollingOfficerPresenter.new(action_log, view_helpers).present
      class PollingOfficerPresenter < Decidim::Log::BasePresenter
        private

        def polling_officer_user
          @polling_officer_user ||= action_log.resource&.user
        end

        def polling_officer_user_extra
          {
            "name" => polling_officer_user.name,
            "nickname" => polling_officer_user.nickname
          }
        end

        def polling_officer_user_presenter
          @polling_officer_user_presenter ||= Decidim::Log::UserPresenter.new(polling_officer_user, h, polling_officer_user_extra)
        end

        def i18n_params
          super.merge(
            polling_officer_user: polling_officer_user.present? ? polling_officer_user_presenter.present : resource_presenter.try(:present)
          )
        end

        def action_string
          case action
          when "create", "delete"
            "decidim.votings.admin_log.polling_officer.#{action}"
          else
            super
          end
        end
      end
    end
  end
end
