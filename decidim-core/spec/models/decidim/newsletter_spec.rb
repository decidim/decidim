# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Newsletter do
    subject { newsletter }

    let(:newsletter) { build(:newsletter) }

    it { is_expected.to be_versioned }

    it "overwrites the log presenter" do
      expect(described_class.log_presenter_class_for(:foo))
        .to eq Decidim::AdminLog::NewsletterPresenter
    end

    describe "validations" do
      it "is valid" do
        expect(subject).to be_valid
      end

      it "is not valid without a subject" do
        newsletter.subject = nil

        expect(subject).not_to be_valid
      end

      it "is not valid if author is from another organization" do
        user = build(:user, organization: build(:organization))
        newsletter = build(:newsletter, organization: build(:organization), author: user)

        expect(newsletter).not_to be_valid
      end
    end

    describe "#url" do
      subject { newsletter.url }

      let(:newsletter) { create(:newsletter, :sent) }
      let(:organization) { newsletter.organization }

      it { is_expected.to eq("http://#{organization.host}:#{Capybara.server_port}/newsletters/#{newsletter.id}") }

      context "when the newsletter is not sent" do
        let(:newsletter) { create(:newsletter) }

        it { is_expected.to eq("#") }
      end
    end

    describe "#notifications_settings_url" do
      subject { newsletter.notifications_settings_url }

      let(:newsletter) { create(:newsletter, :sent) }
      let(:organization) { newsletter.organization }

      it { is_expected.to eq("http://#{organization.host}:#{Capybara.server_port}/notifications_settings") }

      context "when the newsletter is not sent" do
        let(:newsletter) { create(:newsletter) }

        it { is_expected.to eq("#") }
      end
    end

    describe "#unsubscribe_newsletters_url" do
      subject { newsletter.unsubscribe_newsletters_url }

      let(:newsletter) { create(:newsletter, :sent) }
      let(:organization) { newsletter.organization }

      it { is_expected.to eq("http://#{organization.host}:#{Capybara.server_port}/newsletters/unsubscribe") }

      context "when the newsletter is not sent" do
        let(:newsletter) { create(:newsletter) }

        it { is_expected.to eq("#") }
      end
    end

    describe "#organization_official_url" do
      subject { newsletter.organization_official_url }

      let(:newsletter) { create(:newsletter, :sent, organization:) }
      let(:organization) { create(:organization, official_url: "https://example.org") }

      it { is_expected.to eq("https://example.org") }

      context "when the newsletter is not sent" do
        let(:newsletter) { create(:newsletter) }

        it { is_expected.to eq("#") }
      end

      context "when the official URL is not set for the organization" do
        let(:organization) { create(:organization, official_url: nil) }

        it { is_expected.to eq("http://#{organization.host}:#{Capybara.server_port}/") }
      end
    end
  end
end
