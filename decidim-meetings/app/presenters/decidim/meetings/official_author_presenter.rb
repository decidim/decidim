# frozen_string_literal: true

module Decidim
  module Meetings
    #
    # A dummy presenter to abstract out the author of an official meeting.
    #
    class OfficialAuthorPresenter < Decidim::OfficialAuthorPresenter
      def name
        I18n.t("decidim.meetings.models.meeting.fields.official_meeting")
      end
    end
  end
end
