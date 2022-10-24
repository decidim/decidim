# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe WelcomeNotificationEvent do
    subject { described_class.new(resource: user, event_name: "test", user:) }
    let(:user) { create(:user, organization:, name: "James") }
    let(:organization) { create(:organization, name: "Awesome Town") }

    describe "subject" do
      it "has a default" do
        expect(subject.subject).to eq("Thanks for joining Awesome Town!")
      end
    end

    describe "body" do
      it "has a default" do
        expect(subject.body).to include("James")
      end
    end

    describe "email_subject" do
      it "delegates to subject" do
        expect(subject.email_subject).to eq(subject.subject)
      end
    end

    describe "notification_title" do
      it "includes the subject" do
        expect(subject.notification_title).to include(subject.subject)
      end

      it "includes the body" do
        expect(subject.notification_title).to include(subject.body)
      end
    end

    describe "email_greeting" do
      it "is nil" do
        expect(subject.email_greeting).to be_nil
      end
    end

    describe "email_outro" do
      it "is nil" do
        expect(subject.email_outro).to be_nil
      end
    end

    context "when the organization has customized the default welcome message" do
      let(:organization) { create(:organization, name: "Awesome Town", welcome_notification_subject:, welcome_notification_body:) }
      let(:welcome_notification_subject) do
        { en: "Well hello {{name}}" }
      end
      let(:welcome_notification_body) do
        { en: "Welcome to {{organization}}" }
      end

      describe "subject" do
        it "uses the custom version" do
          expect(subject.subject).to eq("Well hello James")
        end
      end

      describe "body" do
        it "uses the custom version" do
          expect(subject.body).to eq("Welcome to Awesome Town")
        end
      end
    end
  end
end
