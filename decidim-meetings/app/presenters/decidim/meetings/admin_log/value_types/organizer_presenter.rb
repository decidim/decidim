# frozen_string_literal: true

module Decidim
  module Meetings
    module AdminLog
      module ValueTypes
        # This class presents the given value as a Decidim::Meetings::Organizer. Check
        # the `DefaultPresenter` for more info on how value presenters work.
        class OrganizerPresenter < Decidim::Log::ValueTypes::DefaultPresenter
          include Rails.application.routes.mounted_helpers
          include ActionView::Helpers::UrlHelper
          # Public: Presents the value as a Decidim::Meetings::Organizer. If the result can
          # be found, it shows its title. Otherwise it shows its ID.
          #
          # Returns an HTML-safe String.
          def present
            return unless value
            return present_organizer if organizer

            I18n.t("not_found", id: value, scope: "decidim.meetings.admin_log.meeting.value_types.organizer_presenter")
          end

          private

          def organizer
            @organizer ||= Decidim::User.find_by(id: value)
          end

          def present_organizer
            return content_tag(:span, present_user_name, class: "logs__log__author") if organizer.blank?

            link_to(
              present_user_name,
              user_path,
              class: "logs__log__author",
              title: "@" + present_user_nickname,
              target: "_blank",
              data: {
                tooltip: true,
                "disable-hover": false
              }, rel: "noopener"
            )
          end

          # Private: Presents the name of the organizer performing the action.
          #
          # Returns an HTML-safe String.
          def present_user_name
            organizer.name.html_safe
          end

          # Private: Presents the nickname of the organizer performing the action.
          #
          # Returns an HTML-safe String.
          def present_user_nickname
            organizer.nickname.html_safe
          end

          # Private: Calculates the path for the organizer. Returns the path of the
          # user profile. It's a public link.
          #
          # Returns an HTML-safe String.
          def user_path
            decidim.profile_path(present_user_nickname)
          end
        end
      end
    end
  end
end
