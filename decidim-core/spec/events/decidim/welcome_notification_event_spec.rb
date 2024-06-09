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
  let(:user) { create(:user, organization:) }
  let(:organization) { create(:organization, name: organization_name) }

  context "with a normal organization name" do
    let(:organization_name) { { ca: "", en: "My Organization", es: "" } }

    describe "#email_subject" do
      subject { event_instance.email_subject }

      it { is_expected.to eq("Thanks for joining My Organization!") }
    end

    describe "#email_intro" do
      subject { event_instance.email_intro }

      it { is_expected.to match(%r{^<p>Hi #{CGI.escapeHTML(user.name)}, thanks for joining My Organization and welcome!</p>}) }
    end
  end

  context "with an organization with an apostrophe" do
    let(:organization_name) { { ca: "", en: "My ol'Organization", es: "" } }

    describe "#email_subject" do
      subject { event_instance.email_subject }

      it { is_expected.to eq("Thanks for joining My ol'Organization!") }
    end

    describe "#email_intro" do
      subject { event_instance.email_intro }

      it { is_expected.to match(%r{^<p>Hi #{CGI.escapeHTML(user.name)}, thanks for joining My ol'Organization and welcome!</p>}) }
    end
  end
end
