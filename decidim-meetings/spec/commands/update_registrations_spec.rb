# frozen_string_literal: true

require "spec_helper"

describe Decidim::Meetings::Admin::UpdateRegistrations do
  let(:meeting) { create(:meeting) }
  let(:invalid) { false }
  let(:registrations_enabled) { true }
  let(:available_slots) { 10 }
  let(:registration_terms) do
    {
      en: "A legal text",
      es: "Un texto legal",
      ca: "Un text legal"
    }
  end
  let(:form) do
    double(
      invalid?: invalid,
      registrations_enabled: registrations_enabled,
      available_slots: available_slots,
      registration_terms: registration_terms
    )
  end

  subject { described_class.new(form, meeting) }

  context "when the form is not valid" do
    let(:invalid) { true }

    it "broadcasts invalid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end

  context "when everything is ok" do
    it "broadcasts ok" do
      expect { subject.call }.to broadcast(:ok)
    end

    it "updates the meeting" do
      subject.call
      expect(meeting.registrations_enabled).to eq(registrations_enabled)
      expect(meeting.available_slots).to eq(available_slots)
      expect(translated(meeting.registration_terms)).to eq "A legal text"
    end
  end
end
