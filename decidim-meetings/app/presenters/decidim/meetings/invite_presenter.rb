# frozen_string_literal: true

module Decidim
  module Meetings
    #
    # Decorator for meeting invites
    #
    class InvitePresenter < SimpleDelegator
      def status
        return I18n.t("accepted", scope: "decidim.meetings.models.invite.status", at: accepted_at) if accepted_at.present?
        return I18n.t("rejected", scope: "decidim.meetings.models.invite.status", at: rejected_at) if rejected_at.present?
        return I18n.t("sent", scope: "decidim.meetings.models.invite.status", at: sent_at) if sent_at.present?

        "-"
      end

      def status_html_class
        return "success" if accepted_at.present?
        return "danger" if rejected_at.present?
        return "warning" if sent_at.present?

        ""
      end
    end
  end
end
