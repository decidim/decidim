# frozen_string_literal: true

require "spec_helper"

describe Decidim::WelcomeNotificationEvent do
  subject { event_instance }

  let(:event_instance) do
    described_class.new(
      resource: user,
      event_name:,
      user:
    )
  end
  let(:event_name) { "decidim.events.core.welcome_notification" }
  let(:user) { create(:user) }

  describe "#email_subject" do
    subject { event_instance.email_subject }

    it { is_expected.to eq("Thanks for joining #{user.organization.name}!") }
  end

  describe "#email_intro" do
    subject { event_instance.email_intro }

    it { is_expected.to match(%r{^<p>Hi #{CGI.escapeHTML(user.name)}, thanks for joining #{CGI.escapeHTML(user.organization.name)} and welcome!</p>}) }
  end
end
