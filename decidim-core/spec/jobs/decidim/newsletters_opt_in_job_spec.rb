# frozen_string_literal: true

require "spec_helper"

describe Decidim::NewslettersOptInJob do
  subject { described_class }

  let(:user) { create(:user, :confirmed, newsletter_notifications_at: nil, newsletter_token: token) }
  let(:token) { SecureRandom.base58(24) }

  describe "queue" do
    it "is queued to events" do
      expect(subject.queue_name).to eq "newsletters_opt_in"
    end
  end

  describe "perform" do
    let(:mailer) { double :mailer }

    it "send an email to user" do
      allow(Decidim::NewslettersOptInMailer)
        .to receive(:notify)
        .with(user, token)
        .and_return(mailer)
      expect(mailer)
        .to receive(:deliver_now)

      subject.perform_now(user, token)
    end
  end
end
