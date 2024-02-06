# frozen_string_literal: true

require "spec_helper"

describe Decidim::Conferences::ConferenceRegistrationNotificationEvent do
  let(:resource) { create(:conference) }
  let(:event_name) { "decidim.events.conferences.conference_registration_validation_pending" }
  let(:user) { create(:user, organization:) }

  include_context "when a simple event" do
    let(:participatory_space) { resource }
  end

  describe "notification_title" do
    it "includes the subject" do
      expect(subject.notification_title).to include("Your registration for the conference <a href=\"#{participatory_space_url}\">#{participatory_space_title}</a> is pending to be confirmed.")
    end
  end
end
