# frozen_string_literal: true

require "spec_helper"

describe "User updates meeting", type: :system do
  let(:form) do
    double(
      invalid?: false,
      title:,
      description:,
      location: "The location of the meeting",
      location_hints: "The location hints of the meeting",
      start_time: 1.day.from_now,
      end_time: 1.day.from_now + 2.hours,
      address: "address",
      latitude: 40.1234,
      longitude: 2.1234,
      taxonomizations:,
      current_user: author,
      current_component: component,
      current_organization: organization,
      registration_type: "on_this_platform",
      available_slots: 0,
      registration_url: "http://decidim.org",
      registration_terms: "This meeting is not blocked",
      registrations_enabled: true,
      clean_type_of_meeting: "online",
      online_meeting_url: "http://decidim.org",
      iframe_embed_type: "embed_in_meeting_page",
      iframe_access_level: "all"
    )
  end
  let(:command) { Decidim::Meetings::UpdateMeeting.new(form, meeting) }

  include_examples "meetings spam analysis" do
    let!(:meeting) do
      create(:meeting,
             component:,
             title: { en: "Some proposal that is not blocked" },
             description: { en: "The body for the meeting." })
    end
  end
end
