# frozen_string_literal: true

module Decidim
  module Meetings
    #
    # Decorator for meeting registrations
    #
    class RegistrationPresenter < SimpleDelegator
      delegate :name, :email, to: :user

      def status
        return I18n.t("attended", scope: "decidim.meetings.models.registration.status") if validated?

        I18n.t("not_attended", scope: "decidim.meetings.models.registration.status")
      end

      def status_html_class
        return "success" if validated?

        "alert"
      end
    end
  end
end
