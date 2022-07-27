# frozen_string_literal: true

require "spec_helper"

describe Decidim::Meetings::RegistrationCodeValidatedEvent do
  include_context "when a simple event"

  let(:resource) { create :meeting }
  let(:event_name) { "decidim.events.meetings.registration_code_validated" }

  let(:registration) { create :registration, meeting: resource }
  let(:extra) { { registration: } }

  it_behaves_like "a simple event"
  it_behaves_like "a translated meeting event"

  describe "resource_text" do
    it "returns the meeting description" do
      expect(subject.resource_text).to eq translated(resource.description)
    end
  end
end
