# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ParticipantsAccountMailer do
    let(:organization) { create(:organization, name: { en: "Test Organization" }) }
    let(:user) { create(:user, organization:, email: "user@example.org", name: "John Doe") }
    let(:default_sender_email) { "test@example.org" }

    describe "#inactivity_notification" do
      let(:mail) { described_class.inactivity_notification(user, 30) }

      it "renders the headers" do
        expect(mail.subject).to eq("Inactive account warning")
        expect(mail.to).to eq([user.email])
        expect(mail.from).to eq([default_sender_email])
      end

      it "includes the organization name in the body" do
        expect(mail.body.encoded).to include("Test Organization")
      end

      it "mentions the number of days before deletion" do
        expect(mail.body.encoded).to include("30 days")
      end

      it "includes the account creation date" do
        expect(mail.body.encoded).to include(user.created_at.strftime("%d %B %Y"))
      end

      it "includes the last connection date or 'never logged in'" do
        if user.current_sign_in_at
          expect(mail.body.encoded).to include(user.current_sign_in_at.strftime("%d %B %Y"))
        else
          expect(mail.body.encoded).to include("never logged in")
        end
      end

      it "provides a warning about account removal" do
        expect(mail.body.encoded).to include("this account has been scheduled for automatic deletion ")
      end
    end

    describe "#removal_notification" do
      let!(:email) { user.email }
      let!(:name) { user.name }
      let!(:locale) { user.locale }
      let(:mail) { described_class.removal_notification(email, name, locale, organization) }

      it "renders the headers" do
        expect(mail.subject).to eq("Inactive account deleted")
        expect(mail.to).to eq([user.email])
        expect(mail.from).to eq([default_sender_email])
      end

      it "includes the organization name in the body" do
        expect(mail.body.encoded).to include("Test Organization")
      end

      it "provides a removal confirmation message" do
        expect(mail.body.encoded).to include("Your Test Organization account has been deleted due to inactivity.")
      end
    end
  end
end
