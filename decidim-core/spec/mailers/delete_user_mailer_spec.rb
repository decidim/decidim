# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe DeleteUserMailer do
    let(:organization) { create(:organization, name: { en: "Test Organization" }) }
    let(:user) { create(:user, organization:, email: "user@example.org", name: "John Doe") }
    let(:default_sender_email) { "test@example.org" }
    let!(:user_email) { user.email }
    let!(:user_name) { user.name }
    let!(:locale) { user.locale }

    describe "#delete" do
      let(:mail) { described_class.delete(user_email:, user_name:, locale:, organization:) }

      it "renders the headers" do
        expect(mail.subject).to eq("Your account has been deleted")
        expect(mail.to).to eq([user.email])
        expect(mail.from).to eq([default_sender_email])
      end

      it "includes the organization name in the body" do
        expect(mail.body.encoded).to include("Test Organization")
      end

      it "provides a removal confirmation message" do
        expect(mail.body.encoded).to include("Your account has been deactivated and is no longer accessible.")
      end
    end
  end
end
