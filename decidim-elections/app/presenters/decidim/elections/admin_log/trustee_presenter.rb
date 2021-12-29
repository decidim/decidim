# frozen_string_literal: true

module Decidim
  module Elections
    module AdminLog
      # This class holds the logic to present a `Decidim::Trustee`
      # for the `AdminLog` log.
      #
      # Usage should be automatic and you shouldn't need to call this class
      # directly, but here's an example:
      #
      #    action_log = Decidim::ActionLog.last
      #    view_helpers # => this comes from the views
      #    TrusteePresenter.new(action_log, view_helpers).present
      class TrusteePresenter < Decidim::Log::BasePresenter
        private

        def trustee_user
          @trustee_user ||= action_log.resource&.user
        end

        def trustee_user_extra
          {
            "name" => trustee_user.name,
            "nickname" => trustee_user.nickname
          }
        end

        def trustee_user_presenter
          @trustee_user_presenter ||= Decidim::Log::UserPresenter.new(trustee_user, h, trustee_user_extra)
        end

        def i18n_params
          super.merge(
            trustee_user: trustee_user.present? ? trustee_user_presenter.present : resource_presenter.try(:present)
          )
        end

        def action_string
          case action
          when "create"
            "decidim.elections.admin_log.trustee.#{action}"
          else
            super
          end
        end
      end
    end
  end
end
