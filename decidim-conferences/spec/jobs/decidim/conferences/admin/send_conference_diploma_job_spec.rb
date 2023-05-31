# frozen_string_literal: true

require "spec_helper"

describe Decidim::Conferences::Admin::SendConferenceDiplomaJob do
  subject { described_class }

  let(:conference) { create(:conference) }
  let(:conference_registration) { create(:conference_registration, :confirmed, conference:) }

  describe "queue" do
    it "is queued to events" do
      expect(subject.queue_name).to eq "conference_diplomas"
    end
  end

  describe "perform" do
    let(:mailer) { double :mailer }

    it "send an email to user" do
      allow(Decidim::Conferences::Admin::SendConferenceDiplomaMailer)
        .to receive(:diploma)
        .with(conference, conference_registration.user)
        .and_return(mailer)
      expect(mailer)
        .to receive(:deliver_later)

      subject.perform_now(conference)
    end
  end
end
