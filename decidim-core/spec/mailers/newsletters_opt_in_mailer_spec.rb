# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe NewslettersOptInMailer, type: :mailer do
    let(:user) { create(:user, :confirmed, organization:, newsletter_notifications_at: nil, newsletter_token: token) }
    let(:token) { SecureRandom.base58(24) }
    let(:organization) { create(:organization) }
    let(:decidim) { Decidim::Core::Engine.routes.url_helpers }

    describe "notify" do
      let(:mail) { described_class.notify(user, token) }

      it "parses the subject" do
        expect(mail.subject).to eq("Do you want to keep receiving relevant information about #{organization.name}?")
      end

      it "parses the body" do
        expect(email_body(mail)).to include("General Data Protection Regulation (GDPR) of May 25, 2018")
      end

      it "parses the link" do
        expect(mail).to have_link("Yes, I want to continue receiving relevant information", href: decidim.newsletters_opt_in_url(token:, host: organization.host))
      end
    end
  end
end
