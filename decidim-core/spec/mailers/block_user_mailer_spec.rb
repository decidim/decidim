# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe BlockUserMailer, type: :mailer do
    let(:user) { create(:user, :confirmed, organization:, newsletter_notifications_at: nil, newsletter_token: token) }
    let(:token) { SecureRandom.base58(24) }
    let(:organization) { create(:organization) }
    let(:organization_url) { "http://www.example.com" }
    let(:decidim) { Decidim::Core::Engine.routes.url_helpers }

    describe "notify" do
      let(:mail) { described_class.notify(user, token) }

      it "parses the subject" do
        expect(mail.subject).to eq("Your account was blocked by #{organization.name}")
      end

      it "parses the body" do
        expect(email_body(mail)).to include("Your account was blocked.")
        expect(email_body(mail)).to include("Reason: ")
      end
    end
  end
end
